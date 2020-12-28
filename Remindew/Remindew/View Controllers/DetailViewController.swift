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
    @IBOutlet var cameraButtonLabel: UIBarButtonItem!
    @IBOutlet var daySelectorOutlet: DaySelectionView!
    @IBOutlet var dateLabel: UIBarButtonItem!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var dayProgressView: UIProgressView!
    @IBOutlet var notesButtonLabel: UIBarButtonItem!
    
    // MARK: - Actions
    @IBAction func notesButtonTapped(_ sender: UIBarButtonItem) {
        print("notesButtonTapped")
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
        print("waterPlantButtonTapped")
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
            
            // if it DOES need to be watered, update needsWatering to false
            if existingPlant.needsWatering {
                plantController?.updatePlantWithWatering(plant: existingPlant, needsWatering: false)
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// Takes user to screen with larger image view and photo/visual options
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        print("CameraButton tapped")
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let appearanceVC = storyboard.instantiateViewController(identifier: "AppearanceViewControllerID") as? AppearanceViewController {
            appearanceVC.modalPresentationStyle = .automatic
            appearanceVC.view.backgroundColor = .orange
            appearanceVC.mainImage = imageView.image
            present(appearanceVC, animated: true, completion: nil)
        }
//        // dismiss keyboards so they don't stay up when library is loading
//        nicknameTextField.resignFirstResponder()
//        speciesTextField.resignFirstResponder()
//        presentPhotoActionSheet()
    }
        
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
                    self.makeNotificationsPermissionAlert()
                }
            }
        }
    }
    
    // MARK: - Properties
    
    var plantController: PlantController?
    
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds what we get back from notepad vc
    var notePad: NotePad?
    
    /// Holds the PlantSearchResult array we get in network call
    var plantSearchResults: [PlantSearchResult] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }
    
    /// Holds scientificName grabbed from plant species search
    var fetchedScientificName = ""
    
    /// Array of random plant nicknames for when a user doesn't want to create their own
    let randomNicknames: [String] = ["Twiggy", "Leaf Erikson", "Alvina", "Thornhill", "Plant 43",
                                    "Entty", "Lily", "Greenman", "Bud Dwyer",
                                    "Cilan", "Milo", "Erika", "Gardenia", "Ramos"]
    
    /// Nav bar date: Sun 11/29
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/d"
        return formatter
    }
    
    /// Last Watered Text View / Button title
    var dateFormatter2: DateFormatter {
        let formatter = DateFormatter()
//            formatter.dateFormat = "EEEE MMM d, h:mm a"
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    /// Loading indicator displayed while searching for a plant
    let spinner = UIActivityIndicatorView(style: .large)
        
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        UINavigationBar.appearance().barTintColor = UIColor.customBackgroundColor
//        UINavigationBar.appearance().isTranslucent = false
        
        // import SVG version instead later?
        if #available(iOS 14.0, *) {
            notesButtonLabel.image = UIImage(systemName: "note.text")
        }
        
        resultsTableView.backgroundView = spinner
        spinner.color = .leafGreen
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.isHidden = true
        
        // makes imageView a circle
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        UIImage.applyLowerPortionGradient(imageView: imageView)
        
        dateLabel.title = dateFormatter.string(from: Date()).capitalized
        // Lets button be disabled with a custom color
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        
        // Hides Keyboard when tapping outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // so you can still click on the table view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        nicknameTextField.borderStyle = .none
        nicknameTextField.delegate = self
        nicknameTextField.attributedPlaceholder = NSAttributedString(string: "Nickname",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        speciesTextField.borderStyle = .none
        speciesTextField.delegate = self
        speciesTextField.returnKeyType = .search
        speciesTextField.attributedPlaceholder = NSAttributedString(string: "Type of plant",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        plantButton.backgroundColor = .mixedBlueGreen
        plantButton.layer.cornerRadius = plantButton.frame.height / 2
        waterPlantButton.backgroundColor = .waterBlue
        waterPlantButton.layer.cornerRadius = waterPlantButton.frame.height / 2
            
        nicknameTextField.autocorrectionType = .no
        speciesTextField.autocorrectionType = .no
        
        datePicker.contentHorizontalAlignment = .right

        updateViews()
    }
        
    // doing this in viewDIDAppear is a little too slow, but viewWillAppear causes lag on iphone8 sim somehow
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will Appeara")
        // if the view appears and there's no text, auto "click" into first textfield
        if nicknameTextField.text == "" {
            nicknameTextField.becomeFirstResponder()
        }
        
        UIView.animate(withDuration: 0.4) {
            self.dayProgressView.setProgress(1.0, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // hide tableview when this screen disappears
        resultsTableView.isHidden = true
    }
    
    // MARK: - Helpers
    
    /// Update all views depending on if in Edit/Add mode
    func updateViews() {
        
        // update date label at least once a day so it displays correct date
        dateLabel.title = dateFormatter.string(from: Date()).capitalized
        
        // will crash if view isn't loaded yet
        guard isViewLoaded else {return}
                
        // DETAIL/EDIT MODE
        if let plant = plant {
            
            notePad = NotePad(notes: plant.notes!, mainTitle: plant.mainTitle!, mainMessage: plant.mainMessage!, mainAction: plant.mainAction!, location: plant.location!, scientificName: plant.scientificName!)
            
            // try to load saved image
            if let image = UIImage.loadImageFromDiskWith(fileName: "userPlant\(plant.identifier!)") {
                imageView.image = image
            }
        
            plantButton.setTitle(NSLocalizedString("Save Changes", comment: "Save changes made to plant"), for: .normal)
            
            // Title says how many times a week plant needs water
            if plant.frequency!.count == 7 {
                title = NSLocalizedString("Every day", comment: "7 times a week")
            }
            else if plant.frequency!.count == 1 {
                title = NSLocalizedString("Once a week", comment: "1 time a week")
            }
            else {
                title = "\(plant.frequency!.count)" + NSLocalizedString(" times a week", comment: "Water (X) times a week")
            }
            
            nicknameTextField.text = plant.nickname
            speciesTextField.text = plant.species
            datePicker.date = plant.water_schedule!
            daySelectorOutlet.selectDays((plant.frequency)!)
            fetchedScientificName = plant.scientificName ?? ""
            waterPlantButton.isHidden = false
            
            // plant DOES need to be watered
            if plant.needsWatering {
                waterPlantButton.setTitle(plant.mainAction, for: .normal)
                // old
//                waterPlantButton.setTitle(NSLocalizedString("Water Plant", comment: "button to water plant"), for: .normal)
                waterPlantButton.isEnabled = true
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
//            textView.text = "Please enter a plant nickname, species, and select reminder days"
        }
        
        plantButton.performFlare()
        // start 0.5 seconds later?
        waterPlantButton.performFlare()
    }
    
    /// Creates or Edits a plant
    private func addOrEditPlant() {
        // before EDIT or ADD, first check for:
        
        // 1. nickname has text AND not empty, else display alert for this
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            makeNicknameAlert()
            return
        }
        
        // 2. species has text AND not empty, else display alert for this
        guard let species = speciesTextField.text, !species.isEmpty else {
            makeSpeciesAlert()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        // Return false is no days are selected, true if there's at least 1 day selected
        let daysAreSelected: Bool = daySelectorOutlet.returnDaysSelected().count > 0
        
        // 3. daysAreSelected is true, else display alert for this
        if !daysAreSelected {
            makeDaysAlert()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        // Check if we should save image
        var imageToSave: UIImage?
        
        // If imageView.image is NOT the default one, save it. Else, don't save
        // Check default image manually here because it won't work with .logoImage for some reason
        if imageView.image.hashValue != UIImage(named: "plantslogoclear1024x1024").hashValue {
            print("Image in imageView is NOT default one")
            imageToSave = imageView.image ?? .logoImage
        }
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
                
            var emptyNotepad = NotePad()
            if let fullNotepad = notePad {
                emptyNotepad = fullNotepad
            }
            
            plantController?.update(nickname: nickname.capitalized,
                                   species: species.capitalized,
                                   water_schedule: datePicker.date,
                                   frequency: daySelectorOutlet.returnDaysSelected(),
                                   scientificName: emptyNotepad.scientificName,
                                   notepad: emptyNotepad,
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
            
            var emptyNotepad = NotePad()
            if let fullNotepad = notePad {
                emptyNotepad = fullNotepad
            }
            
            let plant = plantController?.createPlant(nickname: nickname.capitalized,
                                        species: species.capitalized,
                                        date: datePicker.date,
                                        frequency: daySelectorOutlet.returnDaysSelected(),
                                        scientificName: emptyNotepad.scientificName,
                                        notepad: emptyNotepad)
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
    
    /// Enters a random nickname in nickname textfield so user doesn't have to make up their own
    private func chooseRandomNickname() {
        let randomInt = Int.random(in: 0..<randomNicknames.count)
        print("randomInt = \(randomInt)")
        nicknameTextField.text = randomNicknames[randomInt]
    }
    
    // MARK: - Photos
    
    /// Presents and action sheet with options to use camera to take photo or just choose from library
    @objc func presentPhotoActionSheet() {
        print("presentPhotoActionSheet")
        
        let act = UIAlertController(title: NSLocalizedString("Add Plant Image", comment: "Image Action Sheet Title"),
                                    message: nil,
                                    preferredStyle: .actionSheet)
        
        // Take Photo
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("Take a Photo", comment: "Use Camera to take photo"),
                                            style: .default,
                                            handler: takePhoto)
        act.addAction(takePhotoAction)
        
        // Choose Photo
        let choosePhotoAction = UIAlertAction(title: NSLocalizedString("Choose from Library", comment: "Choose image from photos"),
                                              style: .default,
                                              handler: presentImagePickerController)
        act.addAction(choosePhotoAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                         style: .cancel)
        act.addAction(cancelAction)
        present(act, animated: true)
    }
    
    /// Lets user choose an image from their photo library (no permission required)
    private func presentImagePickerController(action: UIAlertAction) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    /// Brings up camera (if permitted) to let user take a photo of their plant
    private func takePhoto(action: UIAlertAction) {
        print("take photo")
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined, .denied, .restricted:
            makeCameraUsagePermissionAlert()
            return
        case .authorized:
            print("Authorized camera in takePhoto")
        default:
            print("Default in takePhoto")
        }
        
        // check if we have access to Camera (if not, present an alert with option to go to Settings). Just in case
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Error: camera is unavailable")
            makeCameraUsagePermissionAlert()
            return
        }
        
        let viewController = UIImagePickerController()
        
        viewController.sourceType = .camera
        viewController.allowsEditing = true
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    // MARK: - Alerts
    
    /// Presents an alert for when a user did not usage of their camera and lets them go to Settings to change it (will restart app though)
    private func makeCameraUsagePermissionAlert() {
    
        // add two options
        let title = NSLocalizedString("Camera Access Denied",
                                      comment: "Title for camera usage not allowed")
        let message = NSLocalizedString("Please allow camera usage by going to Settings and turning Camera access on", comment: "Error message for when camera access is not allowed")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("selected OK option")
        }
        let settingsString = NSLocalizedString("Settings", comment: "String for Settings option")
        let settingsAction = UIAlertAction(title: settingsString, style: .default) { _ in
            // take user to Settings app
            print("selected Settings option")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for when a user did not allow notifications at launch and lets them go to Settings to change before they make/edit a plant
    private func makeNotificationsPermissionAlert() {
    
        // add two options
        let title = NSLocalizedString("Notifications Disabled",
                                      comment: "Title for notification permissions not allowed")//"Notifications Disabled"
        let message = NSLocalizedString("Please allow notifications by going to Settings and allowing Notifications, Banners, Sounds, and Badges.", comment: "Error message for when notifications are not allowed")//"Please allow notifications by going to Settings and allowing Notifications, Banners, Sounds, and Badges."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("selected OK option")
        }
        let settingsString = NSLocalizedString("Settings", comment: "String for Settings option")
        let settingsAction = UIAlertAction(title: settingsString, style: .default) { _ in
            // take user to Settings app
            print("selected Settings option")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing text in nickname textfield. Inserts random nickname or clicks in nickname textfield for user to enter their own
    private func makeNicknameAlert() {
        
        let title = NSLocalizedString("Missing Nickname",
                                      comment: "Title for no nickname in textfield")
        let message = NSLocalizedString("Please enter a custom nickname for your plant or select a random nickname",
                                        comment: "Message for when nickname is missing in textfield")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //alertController.view.tintColor = .lightLeafGreen
        
        let alertAction = UIAlertAction(title: NSLocalizedString("Custom", comment: "User generated name"), style: .default) { _ in
            self.nicknameTextField.becomeFirstResponder()
        }
        let randomAction = UIAlertAction(title: NSLocalizedString("Random", comment: "Randomly generated name"), style: .default) { _ in
            self.chooseRandomNickname()
            self.nicknameTextField.becomeFirstResponder()
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(randomAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing text in species textfield. Clicks in species textfield when user clicks OK
    private func makeSpeciesAlert() {
        let title = NSLocalizedString("Missing Species Name",
                                      comment: "Title for when species name is missing in textfield")
        let message = NSLocalizedString("Please enter a species for your plant.\nExample: \"Peace Lily\"",
                                        comment: "Message for when species name is missing in textfield")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // handler could select the textfield it needs or change textview text??
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.speciesTextField.becomeFirstResponder()
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing days and changes text view to give a hint
    private func makeDaysAlert() {
        let title = NSLocalizedString("Missing Watering Days",
                                      comment: "Title for when watering days are missing")
        let message = NSLocalizedString("Please select which days you would like to receive reminders",
                                        comment: "Message for when watering days are missing")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
        self.dayProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
//            self.textView.text = NSLocalizedString("Select at least one of the days below",
//                                                   comment: "Hint on how to set a least one reminder")
            UIView.animate(withDuration: 0.275) {
                self.dayProgressView.setProgress(1.0, animated: true)
            }
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Makes custom alerts with given title and message for network errors
    private func makeAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
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
            makeAlert(title: NSLocalizedString("Invalid Species", comment: ".invalidURL"),
                      message: NSLocalizedString("Please enter a valid species name", comment: "invalid URL"))
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
            makeAlert(title: NSLocalizedString("Server Maintenance", comment: "Title for Servers down temporarily"),
                      message: NSLocalizedString("Servers down for maintenance. Please try again later.", comment: "Servers down"))
            return
        default:
            print("default error in searchPlants")
        }
        // Error for all cases that don't have custom ones
        makeAlert(title: NSLocalizedString("Network Error", comment: "any network error"),
                  message: NSLocalizedString("Search feature temporarily unavailable", comment: "any network error"))
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
                        self.makeAlert(title: NSLocalizedString("No Results Found",
                                                                comment: "no search resutls"),
                                       message: NSLocalizedString("Please search for another species",
                                                                  comment: "try another species"))
                    }
                    print("set array to plants we got back")
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

// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // only do the following when in "add mode"
        if let _ = plant { return }
        if textField == nicknameTextField {
//            textView.text = NSLocalizedString("Please enter a nickname for your plant",
//                                              comment: "textview instructions for nickname")
        }
        
        else if textField == speciesTextField {
//            textView.text = NSLocalizedString("Species example: \"Rose\"\nPress \"search\" to search",
//                                              comment: "textview instructions for species/search")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Clicked "Search" in species textfield
        if textField == speciesTextField {
            print("Return inside speciesTextfield")

            // dismiss keyboard
            textField.resignFirstResponder()
            
            // if there's still a search going on, exit out
            if spinner.isAnimating {
                print("still spinning")
                return true
            }
            
            guard let unwrappedTerm = speciesTextField.text, !unwrappedTerm.isEmpty else { return true }
                    
            // get rid of any spaces in search term
            let term = unwrappedTerm.replacingOccurrences(of: " ", with: "")
            
            // show tableview
            resultsTableView.isHidden = false
            
            // start animating spinner
            spinner.startAnimating()
            
            // check if we need a new token first
            if plantController?.newTempTokenIsNeeded() == true {
                print("new token needed, fetching one first")
                plantController?.signToken(completion: { (result) in
                    do {
                        let message = try result.get()
                        DispatchQueue.main.async {
                            print("success in signToken: \(message)")
                            self.performPlantSearch(term)
                        }
                    } catch {
                        if let error = error as? NetworkError {
                            print("error in detailVC when signing token")
                            DispatchQueue.main.async {
                                self.spinner.stopAnimating()
                                self.handleNetworkErrors(error)
                            }
                        }
                    }
                })
            }
            
            // No new token needed
            else {
                print("No token needed, searching")
                performPlantSearch(term)
            }
        }
        
        // Clicked "Return" in nickname textfield
        if textField == nicknameTextField {
            // go to next textfield (species)
            speciesTextField.becomeFirstResponder()
        }
        
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

/// For accessing the photo library
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        // .editedImage instead? (used to say .originalImage)
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantSearchResults.count//(plantController?.plantSearchResults.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cast as a custom tableview cell (after I make one)
        guard let resultCell = resultsTableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
    
        let plantResult = plantSearchResults[indexPath.row]//plantController?.plantSearchResults[indexPath.row]
        
        // common name
        resultCell.commonNameLabel.text = plantResult.commonName?.capitalized ?? "No common name"
        
        // scientific name
        resultCell.scientificNameLabel.text = plantResult.scientificName ?? "No scientific name"
        
        resultCell.spinner.startAnimating()
        // image
        // store returned UUID? for task for later
        let token = plantController?.loadImage(plantResult.imageUrl) { result in
            do {
                
                // extract result (UIImage)
                let image = try result.get()
                
                // if we get an image, display in cell's image view on main queue
                DispatchQueue.main.async {
                    resultCell.plantImageView?.image = image
                    resultCell.spinner.stopAnimating()
                }
            } catch {
                // do something if there's an error
                // set image to default picture?
                print("Error in result of loadImage in cellForRowAt")
                DispatchQueue.main.async {
                    resultCell.plantImageView?.image = .logoImage
                    resultCell.spinner.stopAnimating()
                }
            }
        }
        
        // use UUID? we just made to now cancel the load for it
        resultCell.onReuse = {
            // when cell is reused, try to cancel the task it started here
            if let token = token {
                resultCell.spinner.stopAnimating()
                self.plantController?.cancelLoad(token)
            }
        }
        
        return resultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let plantResultCell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell
        let scientificName = plantResultCell?.scientificNameLabel.text ?? ""
        imageView.image = plantResultCell?.plantImageView.image
        
        // if we DO want it to put common name selected into species field
        if UserDefaults.standard.bool(forKey: .resultFillsSpeciesTextfield) && plantResultCell?.commonNameLabel.text != "No common name"{
            speciesTextField.text = plantResultCell?.commonNameLabel.text
        }
        
        fetchedScientificName = scientificName
    }
}

// MARK: - NotepadDelegate

extension DetailViewController: NotepadDelegate {
    // receive the notepad we made in other screen and set ours to what we get back
    func didMakeNotepad(notepad: NotePad) {
        self.notePad = notepad
    }
    
    // same as above but this way we can update views with "new" plant
    func didMakeNotepadWithPlant(notepad: NotePad, plant: Plant) {
        self.notePad = notepad
        self.plant = plant
    }
}
