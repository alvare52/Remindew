//
//  DetailViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var plantButton: UIButton!
    @IBOutlet weak var backButton: UINavigationItem!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var waterPlantButton: UIButton!
    @IBOutlet var daySelectorOutlet: DaySelectionView!
    @IBOutlet var dateLabel: UIBarButtonItem!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var dayProgressView: UIProgressView!
    @IBOutlet var notesButtonLabel: UIBarButtonItem!
    @IBOutlet var reminderButtonLabel: UIBarButtonItem!
    @IBOutlet var spacerButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var plantController: PlantController?
    
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds what we get back from NotepadViewController
    var notePad: NotePad?
    
    /// Holds what we get back from AppearanceViewController
    var appearanceOptions: AppearanceOptions?
    
    /// Holds PlantSearchResult we get back from search vc
    var plantSearchResult: PlantSearchResult?
    
    /// Holds the PlantSearchResult array we get in network call
    var plantSearchResults: [PlantSearchResult] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }
        
    /// Holds array of Reminders to belong to self.plant?
    var reminders: [Reminder] {
        
        // Edit Mode
        if let plant = plant {
            var resultsArray = plant.reminders?.allObjects as! Array<Reminder>
            resultsArray.sort() { $0.alarmDate! < $1.alarmDate! }
            return resultsArray
        }
        // Add Mode
        return []
    }
    
    /// Holds scientificName grabbed from plant species search
    var fetchedScientificName = ""
    
    /// Loading indicator displayed while searching for a plant
    let spinner = UIActivityIndicatorView(style: .large)
    
    // MARK: - Actions
    @IBAction func notesButtonTapped(_ sender: UIBarButtonItem) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let notepadVC = storyboard.instantiateViewController(identifier: "NotepadViewControllerID") as? NotepadViewController {
            notepadVC.modalPresentationStyle = .automatic
            notepadVC.plantController = plantController
            notepadVC.plant = plant
            notepadVC.notepadDelegate = self
            present(notepadVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func waterPlantButtonTapped(_ sender: UIButton) {
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
            
            // if it DOES need to be watered, update needsWatering to false
            if existingPlant.needsWatering {
                plantController?.updatePlantWithWatering(plant: existingPlant, needsWatering: false)
            }
            navigationController?.popViewController(animated: true)
        }
    }
        
    /// Takes user to Add Reminder Screen to create a Reminder
    @IBAction func reminderButtonTapped(_ sender: UIBarButtonItem) {
        
        if reminders.count >= 7 {
            UIAlertController.makeAlert(title: .reminderLimitTitleLocalizedString,
                                        message: .reminderLimitMessageLocalizedString,
                                        vc: self)
        }
        
        // if in Edit Mode, go to ReminderViewController. Add Mode, go to SearchViewController
        plant != nil ? presentReminderViewController() : presentSearchViewController()
    }
        
    /// Add/Save plant but first checks if notifications are enabled. Presents alert or add/edits entered plant
    @IBAction func plantButtonTapped(_ sender: UIButton) {
        
        // first check if notifications are enabled (alerts, badges, and sounds)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            // only create/edit plants if notifications are enabled
            if settings.alertSetting == .enabled  && settings.badgeSetting == .enabled && settings.soundSetting == .enabled {
                print("Permission Granted (.alert, .badge, .sound)")
                DispatchQueue.main.async {
                    self.addOrEditPlant()
                }
            }
            // if notifications are NOT enabled, let user know and take them to Settings app
            else {
                // local alert saying it needs permission
                print("Notification permissions NOT granted")
                DispatchQueue.main.async {
                    UIAlertController.makeNotificationsPermissionAlert(vc: self)
                }
            }
        }
    }
    
    /// Tapping on imageView presents AppearanceViewController
    @objc private func tappedOnImageView() {                    
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let appearanceVC = storyboard.instantiateViewController(identifier: "AppearanceViewControllerID") as? AppearanceViewController {
            appearanceVC.modalPresentationStyle = .automatic
            appearanceVC.mainImage = imageView.image
            appearanceVC.appearanceDelegate = self
            appearanceVC.plant = plant
            present(appearanceVC, animated: true, completion: nil)
        }
    }
        
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .customDetailBackgroundColor//.customCellColor
        resultsTableView.backgroundColor = .customDetailBackgroundColor//.customCellColor
        
        spacerButton.tintColor = .clear
        spacerButton.isEnabled = false
        
        // Listen for a notification coming in while app is in the foreground to update detail screen
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshReminders),
                                               name: .checkWateringStatus,
                                               object: nil)
        
        let backButton = UIBarButtonItem(title: NSLocalizedString("Back", comment: "back button"))
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        resultsTableView.backgroundView = spinner
        spinner.color = .leafGreen
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.separatorInset = .zero
        resultsTableView.layoutMargins = .zero
        
        // makes imageView a circle
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        UIImage.applyLowerPortionGradient(imageView: imageView)
        
        dateLabel.title = DateFormatter.navBarDateFormatter.string(from: Date())
        // Lets button be disabled with a custom color
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        
        addTouchGestures()
        
        nicknameTextField.autocorrectionType = .no
        nicknameTextField.borderStyle = .none
        nicknameTextField.delegate = self
        nicknameTextField.attributedPlaceholder = NSAttributedString(string: .nicknameLocalizedString,
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        speciesTextField.autocorrectionType = .no
        speciesTextField.borderStyle = .none
        speciesTextField.delegate = self
        speciesTextField.returnKeyType = .search
        speciesTextField.attributedPlaceholder = NSAttributedString(string: .typeOfPlantLocalizedString,
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        plantButton.backgroundColor = UIColor.colorsArray[0]
        plantButton.layer.cornerRadius = plantButton.frame.height / 2
        waterPlantButton.backgroundColor = UIColor.colorsArray[1]
        waterPlantButton.layer.cornerRadius = waterPlantButton.frame.height / 2
                    
        updateViews()
    }
        
    // doing this in viewDIDAppear is a little too slow, but viewWillAppear causes lag on iphone8 sim somehow
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if nicknameTextField.text == "" {
            nicknameTextField.becomeFirstResponder()
        }
        
        UIView.animate(withDuration: 0.4) {
            self.dayProgressView.setProgress(1.0, animated: true)
        }
    }
        
    // MARK: - Helpers
    
    /// Update all views depending on if in Edit/Add mode
    func updateViews() {
        
        // update date label at least once a day so it displays correct date
        dateLabel.title = DateFormatter.navBarDateFormatter.string(from: Date())
        
        // will crash if view isn't loaded yet
        guard isViewLoaded else {return}
                
        // DETAIL/EDIT MODE
        if let plant = plant {
            
            notePad = NotePad(notes: plant.notes!, mainTitle: plant.mainTitle!, mainMessage: plant.mainMessage!, mainAction: plant.mainAction!, location: plant.location!, scientificName: plant.scientificName!)
            
            // try to load saved image
            if let image = UIImage.loadImageFromDiskWith(fileName: "userPlant\(plant.identifier!)") {
                imageView.image = image
            }
        
            plantButton.setTitle(NSLocalizedString("Save", comment: "Done button"), for: .normal)
            
            // Title displays location or how many times a week plant needs water
            if plant.location != "" {
                title = plant.location!
            } else {
                if plant.frequency!.count == 7 {
                    title = NSLocalizedString("Every day", comment: "7 times a week")
                }
                else if plant.frequency!.count == 1 {
                    title = NSLocalizedString("Once a week", comment: "1 time a week")
                }
                else {
                    title = "\(plant.frequency!.count)" + NSLocalizedString(" times a week", comment: "Water (X) times a week")
                }
            }
            
            nicknameTextField.text = plant.nickname
            speciesTextField.text = plant.species
            datePicker.date = plant.water_schedule!
            daySelectorOutlet.selectDays((plant.frequency)!)
            waterPlantButton.isHidden = false
            
            // unhide reminder button
            reminderButtonLabel.image = UIImage(systemName: "bell.circle")

            plantButton.backgroundColor = UIColor.colorsArray[Int(plant.plantColorIndex)]
            waterPlantButton.backgroundColor = UIColor.colorsArray[Int(plant.actionColorIndex)]
            
            // plant DOES need to be watered
            if plant.needsWatering {
                waterPlantButton.setTitle(plant.mainAction, for: .normal)
                waterPlantButton.isEnabled = true
                waterPlantButton.performFlare()
            }
            
            // plant does NOT need to be watered
            else {
                waterPlantButton.isHidden = true
                waterPlantButton.isEnabled = false
            }
        }
         
        // ADD MODE
        else {
            plantButton.setTitle(NSLocalizedString("Add Plant", comment: "Add a plant to your collection"), for: .normal)
            title = NSLocalizedString("Add New Plant", comment: "Title for Add Plant screen")
            nicknameTextField.text = ""
            speciesTextField.text = ""
            waterPlantButton.isHidden = true
            
            // change reminderButton to search button
            reminderButtonLabel.image = UIImage(systemName: "magnifyingglass")
            
            plantButton.performFlare()
        }
    }
    
    /// Creates or Edits a plant
    private func addOrEditPlant() {
        
        // before EDIT or ADD, first check for:
        
        // 1. If nickname is not entered, give random one
        var nickname = ""
        if let possibleNickname = nicknameTextField.text, !possibleNickname.isEmpty {
            nickname = possibleNickname
        } else {
            nickname = String.returnRandomNickname()
        }
        
        // 2. species has text AND not empty, else display alert for this
        guard let species = speciesTextField.text, !species.isEmpty else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            UIAlertController.makeSpeciesAlert(textField: speciesTextField, vc: self)
            return
        }
        
        // Return false is no days are selected, true if there's at least 1 day selected
        let daysAreSelected: Bool = daySelectorOutlet.returnDaysSelected().count > 0
        
        // 3. daysAreSelected is true, else display alert for this
        if !daysAreSelected {
            UIAlertController.makeDaysAlert(progressView: dayProgressView, vc: self)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        // Check if we should save image
        var imageToSave: UIImage?
        
        // If imageView.image is NOT the default one, save it. Else, don't save
        // Check default image manually here because it won't work with .logoImage for some reason
        if imageView.image.hashValue != UIImage(named: "plantslogoclear1024x1024").hashValue {
            imageToSave = imageView.image ?? .logoImage
        }
                
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
                
            var emptyNotepad = NotePad()
            if let fullNotepad = notePad {
                emptyNotepad = fullNotepad
            }
            
            var selectedAppearanceOptions = AppearanceOptions(plantIconIndex: existingPlant.plantIconIndex,
                                                              plantColorIndex: existingPlant.plantColorIndex,
                                                              actionIconIndex: existingPlant.actionIconIndex,
                                                              actionColorIndex: existingPlant.actionColorIndex)
            
            // if we got some new ones from AVC, use those instead
            if let fullAppearanceOptions = appearanceOptions {
                selectedAppearanceOptions = fullAppearanceOptions
            }
                        
            plantController?.update(nickname: nickname.capitalized,
                                   species: species.capitalized,
                                   water_schedule: datePicker.date,
                                   frequency: daySelectorOutlet.returnDaysSelected(),
                                   scientificName: plantSearchResult?.scientificName ?? emptyNotepad.scientificName,
                                   notepad: emptyNotepad,
                                   appearanceOptions: selectedAppearanceOptions,
                                   plant: existingPlant)
            // save image
            let imageName = "userPlant\(existingPlant.identifier!)"
            
            // if there is an image to save only
            if let image = imageToSave {
                UIImage.saveImage(imageName: imageName, image: image)
            }
        }
            
        // If there is NO plant (ADD)
        else {
            
            var emptyNotepad = NotePad(scientificName: plantSearchResult?.scientificName ?? "")
            if let fullNotepad = notePad {
                emptyNotepad = fullNotepad
            }
            
            var emptyAppearanceOptions = AppearanceOptions()
            if let fullAppearanceOptions = appearanceOptions {
                emptyAppearanceOptions = fullAppearanceOptions
            }
            
            let plant = plantController?.createPlant(nickname: nickname.capitalized,
                                        species: species.capitalized,
                                        date: datePicker.date,
                                        frequency: daySelectorOutlet.returnDaysSelected(),
                                        scientificName: emptyNotepad.scientificName,
                                        notepad: emptyNotepad,
                                        appearanceOptions: emptyAppearanceOptions)
            // save image
            let imageName = "userPlant\(plant!.identifier!)"
            
            // if there is an image to save only
            if let image = imageToSave {
                UIImage.saveImage(imageName: imageName, image: image)
            }
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        
        // Vibrate
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Go back to main screen
        navigationController?.popViewController(animated: true)
    }
        
    /// Refreshes all Plant reminders when a notification goes off while on the Detail screen
    @objc func refreshReminders() {
        resultsTableView.reloadData()
    }
    
    /// Adds up swipe and down swipe gesture recognizers to dismiss keyboard and tap gesture on imageView to present AppearanceViewController
    private func addTouchGestures() {
        
        // Hides Keyboard when swiping up
        let swipe = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        // so you can still click on the table view
        swipe.cancelsTouchesInView = false
        swipe.direction = .up
        view.addGestureRecognizer(swipe)
        
        // Hides Keyboard when swiping down
        let downSwipe = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        // so you can still click on the table view
        downSwipe.cancelsTouchesInView = false
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        // Tap Gesture Recognizer for imageView
        let tapOnImageView = UITapGestureRecognizer(target: self, action: #selector(tappedOnImageView))
        imageView.addGestureRecognizer(tapOnImageView)
        imageView.isUserInteractionEnabled = true
    }
    
    /// Modally presents ReminderViewController, passing along plant, plantController, and self as a delegate
    private func presentReminderViewController() {
        
        guard let plant = plant else { return }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let reminderVC = storyboard.instantiateViewController(identifier: "ReminderViewControllerID") as? ReminderViewController {
            reminderVC.modalPresentationStyle = .automatic
            reminderVC.plantController = plantController
            reminderVC.plant = plant
            reminderVC.reminderDelegate = self
            present(reminderVC, animated: true, completion: nil)
        }
    }
    
    /// Presents SearchViewController when hitting "search" in species textfield and passes in search term and starts search
    func presentSearchViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(identifier: "SearchViewControllerID") as? SearchViewController {
            searchVC.modalPresentationStyle = .automatic
            searchVC.plantController = plantController
            searchVC.resultDelegate = self
            searchVC.passedInSearchTerm = self.speciesTextField.text
            present(searchVC, animated: true, completion: nil)
        }
    }
        
    // MARK: - Networking
    
    /// Presents custom alerts for given network error
    func handleNetworkErrors(_ error: NetworkError) {
        switch error {
        case .badAuth:
            print("badAuth in signToken")
        case .noToken:
            print("no token in searchPlants")
        case .invalidURL:
            UIAlertController.makeAlert(title: NSLocalizedString("Invalid Species", comment: ".invalidURL"),
                      message: NSLocalizedString("Please enter a valid species name", comment: "invalid URL"),
                      vc: self)
            return
        case .otherError:
            print("other error in searchPlants")
        case .noData:
            print("No data received or data corrupted")
        case .noDecode:
            print("JSON could not be decoded")
        case .invalidToken:
            print("personal token invalid when sending to get temp token url")
        case .serverDown:
            UIAlertController.makeAlert(title: NSLocalizedString("Server Maintenance", comment: "Title for Servers down temporarily"),
                      message: NSLocalizedString("Servers down for maintenance. Please try again later.", comment: "Servers down"),
                      vc: self)
            return
        default:
            print("default error in searchPlants")
        }
        
        // Error for all cases that don't have custom ones
        UIAlertController.makeAlert(title: NSLocalizedString("Network Error", comment: "any network error"),
                  message: NSLocalizedString("Search feature temporarily unavailable", comment: "any network error"),
                  vc: self)
    }
    
    /// Performs a search for plants species (called inside textfield Return)
    func performPlantSearch(_ term: String) {
        self.plantController?.searchPlantSpecies(term, completion: { (result) in
            
            do {
                let plantResults = try result.get()
                DispatchQueue.main.async {
                    self.plantSearchResults = plantResults
                    self.spinner.stopAnimating()
                    if plantResults.count == 0 {
                        UIAlertController.makeAlert(title: NSLocalizedString("No Results Found",
                                                                comment: "no search resutls"),
                                       message: NSLocalizedString("Please search for another species",
                                                                  comment: "try another species"),
                                       vc: self)
                    }
                }
            } catch {
                if let error = error as? NetworkError {
                    DispatchQueue.main.async {
                        print("Error searching for plants in performPlantSearch")
                        self.spinner.stopAnimating()
                        self.handleNetworkErrors(error)
                    }
                }
            }
        })
    }
}
