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
    @IBOutlet var textView: UITextView!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var dayProgressView: UIProgressView!
    @IBOutlet var speciesProgressView: UIProgressView!
    @IBOutlet var nicknameProgressView: UIProgressView!
    
    // MARK: - Actions
    
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
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        print("CameraButton tapped")
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        presentImagePickerController()
    }
        
    @IBAction func plantButtonTapped(_ sender: UIButton) {
        
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
                            
            plantController?.update(nickname: nickname.capitalized,
                                   species: species.capitalized,
                                   water_schedule: datePicker.date,
                                   frequency: daySelectorOutlet.returnDaysSelected(),
                                   scientificName: fetchedScientificName,
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
            let plant = plantController?.createPlant(nickname: nickname.capitalized,
                                        species: species.capitalized,
                                        date: datePicker.date,
                                        frequency: daySelectorOutlet.returnDaysSelected(),
                                        scientificName: fetchedScientificName)
            // save image
            let imageName = "userPlant\(plant!.identifier!)"
            
            // if there is an image to save only
            if let image = imageToSave {
                UIImage.saveImage(imageName: imageName, image: image)
            }
        }
        
        // Vibrate
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Go back to main screen
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Properties
    
    var plantController: PlantController?
    
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds scientificName grabbed from plant species search
    var fetchedScientificName = ""
    
    /// Array of random plant nicknames for when a user doesn't want to create their own
    let randomNicknames: [String] = ["Twiggy", "Leaf Erikson", "Alvina", "Bulba", "Thornhill", "Plant 43",
                                    "Entty", "Lily"]
    
    /// Presents an alert for missing text in nickname textfield. Inserts random nickname or clicks in nickname textfield for user to enter their own
    private func makeNicknameAlert() {
        // add two options
        let title = "Missing Nickname"
        let message = "Please enter a personal nickname for your plant or select a random nickname"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
        self.nicknameProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: "Personal", style: .default) { _ in
            self.nicknameTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.275) {
                self.nicknameProgressView.setProgress(1.0, animated: true)
            }
        }
        let randomAction = UIAlertAction(title: "Random", style: .default) { _ in
            self.chooseRandomNickname()
            self.nicknameTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.275) {
                self.nicknameProgressView.setProgress(1.0, animated: true)
            }
        }
        alertController.addAction(alertAction)
        alertController.addAction(randomAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing text in species textfield. Clicks in species textfield when user clicks OK
    private func makeSpeciesAlert() {
        let title = "Missing Species Name"
        let message = "Please enter a species for your plant.\nExample: \"Peace Lily\""
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
        self.speciesProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.speciesTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.275) {
                self.speciesProgressView.setProgress(1.0, animated: true)
            }
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing days and changes text view to give a hint
    private func makeDaysAlert() {
        let title = "Missing Watering Days"
        let message = "Please select which days you would like to receive reminders"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
        self.dayProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.textView.text = "Select at least one of the days below"
            UIView.animate(withDuration: 0.275) {
                self.dayProgressView.setProgress(1.0, animated: true)
            }
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Enters a random nickname in nickname textfield so user doesn't have to make up their own
    private func chooseRandomNickname() {
        let randomInt = Int.random(in: 0..<randomNicknames.count)
        print("randomInt = \(randomInt)")
        nicknameTextField.text = randomNicknames[randomInt]
    }
    
    /// Nav bar date: Sun 11/29
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MM/d"
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
        
        // setting to false limits line to 2
//        textView.isScrollEnabled = false
        resultsTableView.backgroundView = spinner
        spinner.color = .leafGreen
        
        // only show it after searching, then hide after choosing plant?
//        resultsTableView.isHidden = true
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // makes imageView a circle
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        
        dateLabel.title = dateFormatter.string(from: Date())
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        
        // Hides Keyboard when tapping outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        // so you can still click on the table view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        nicknameTextField.borderStyle = .none
        nicknameTextField.delegate = self
        
        speciesTextField.borderStyle = .none
        speciesTextField.delegate = self
        speciesTextField.returnKeyType = .search
        
        // Dark -> Light?
        plantButton.applyGradient(colors: [UIColor.leafGreen.cgColor, UIColor.lightLeafGreen.cgColor])
        waterPlantButton.applyGradient(colors: [UIColor.waterBlue.cgColor, UIColor.lightWaterBlue.cgColor])
        
        nicknameTextField.autocorrectionType = .no
        speciesTextField.autocorrectionType = .no
        // NEW
//        datePicker.minimumDate = Date()
        // NEW
        // Should maximumDate be untle the end of the current day?
        datePicker.datePickerMode = .time
        updateViews()
    }
        
    // doing this in viewDIDAppear is a little too slow, but viewWillAppear causes lag on iphone8 sim somehow
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // if the view appears and there's no text, auto "click" into first textfield
        if nicknameTextField.text == "" {
            nicknameTextField.becomeFirstResponder()
        }
        
        // Animate progress views
        UIView.animate(withDuration: 0.6) {
            self.nicknameProgressView.setProgress(1.0, animated: true)
        }
        UIView.animate(withDuration: 0.5) {
            self.speciesProgressView.setProgress(1.0, animated: true)
        }
        UIView.animate(withDuration: 0.4) {
            self.dayProgressView.setProgress(1.0, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // reset array
        plantController?.plantSearchResults = []
    }
    
    /// Updates textView to display tapped cells scientfic name
    private func updateTextView() {
        
        // if in edit mode
        if let plant = plant {
            // Plant that HAS been watered before
            if let lastWatered = plant.lastDateWatered {
                let dateString = dateFormatter2.string(from: lastWatered)
                // replace this with scientific name from API call later
                textView.text = "Last Watered:\n\(dateString)"
            }
            // Plant that HAS NOT been watered before (brand new plant)
            else {
                // lastWatered is nil for some reason
                textView.text = "Brand new plant"
            }
            textView.text += "\n\(fetchedScientificName)"
        }
        
        // if in add mode
        else {
            textView.text = "Please select the preferred reminder days to water your plant"
            textView.text += "\n\(fetchedScientificName)"
        }

    }
    
    func updateViews() {
        
        guard isViewLoaded else {return}
        
        // DETAIL/EDIT MODE
        if let plant = plant {
            
            // try to load saved image
            if let image = UIImage.loadImageFromDiskWith(fileName: "userPlant\(plant.identifier!)") {
                imageView.image = image
            }
        
            plantButton.setTitle("Edit Plant", for: .normal)
            let name = plant.nickname!
            let xAWeek = "\(plant.frequency!.count)x a week"
            title = "\(name) - \(xAWeek)"
            nicknameTextField.text = plant.nickname
            speciesTextField.text = plant.species
            datePicker.date = plant.water_schedule!
            daySelectorOutlet.selectDays((plant.frequency)!)
            fetchedScientificName = plant.scientificName ?? ""
            waterPlantButton.isHidden = false
            
            // plant DOES need to be watered
            if plant.needsWatering {
                waterPlantButton.setTitle("Water Plant", for: .normal)
                waterPlantButton.isEnabled = true
                
            }
            // plant does NOT need to be watered
            else {
                waterPlantButton.isHidden = true
                waterPlantButton.isEnabled = false
            }
            
            // Plant that HAS been watered before
            if let lastWatered = plant.lastDateWatered {
                let dateString = dateFormatter2.string(from: lastWatered)
                // replace this with scientific name from API call later
                textView.text = "Last Watered:\n\(dateString)"
            }
            // Plant that HAS NOT been watered before (brand new plant)
            else {
                // lastWatered is nil for some reason
                textView.text = "Brand new plant"
            }
            textView.text += "\n\(plant.scientificName ?? "")"
        }
         
        // ADD MODE
        else {
            plantButton.setTitle("Add Plant", for: .normal)
            title = "Add New Plant"
            nicknameTextField.text = ""
            speciesTextField.text = ""
            datePicker.date = Date()
            waterPlantButton.isHidden = true
            textView.text = "Please select the preferred reminder days to water your plant"
        }
        
        plantButton.performFlare()
        // start 0.5 seconds later?
        waterPlantButton.performFlare()
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
}

extension DetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Clicked "Search" in species textfield
        if textField == speciesTextField {
            print("Return inside speciesTextfield")

            guard let unwrappedTerm = speciesTextField.text, !unwrappedTerm.isEmpty else { return true }
            
            // dismiss keyboard
            textField.resignFirstResponder()
            
            // get rid of any spaces in search term
            let term = unwrappedTerm.replacingOccurrences(of: " ", with: "")
            
            // start animating spinner
            spinner.startAnimating()
            
            // check if we need a new token first
            if plantController?.newTempTokenIsNeeded() == true {
                
                print("new token needed, fetching one first")
                plantController?.signToken(completion: { (error) in
                    
                    if let error = error {
                        print("error getting new token in textFieldShouldReturn \(error)")
                        // local alert?
                    }
                    
                    DispatchQueue.main.async {
                        
                        // Do search here
                        self.plantController?.searchPlantSpecies(term, completion: { (error) in
                                if let error = error {
                                    print("Error with searchPlantSpeciese in detail VC \(error)")
                                    self.spinner.stopAnimating()
                            }

                            DispatchQueue.main.async {
                                print("Success with searchPlantSpecies in detail VC")
                                // pop up table VC with results? (unhide table view?)
                                self.resultsTableView.reloadData()
                                self.spinner.stopAnimating()
                            }
                        })
                    }
                })
            }
            
            // No new token needed
            else {
                print("No token needed, searching")
                // Do search here
                plantController?.searchPlantSpecies(term, completion: { (error) in
                    if let error = error {
                        // crashes here if no secret API key (so bad URL)
                        print("Error with searchPlantSpeciese in detail VC \(error)")
                        self.spinner.stopAnimating()
                    }

                    DispatchQueue.main.async {
                        print("Success with searchPlantSpecies in detail VC")
                        // pop up table VC with results? (unhide table view?)
                        self.resultsTableView.reloadData()
                        self.spinner.stopAnimating()
                    }
                })
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

/// For accessing the photo library
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (plantController?.plantSearchResults.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cast as a custom tableview cell (after I make one)
        guard let resultCell = resultsTableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
    
        let plantResult = plantController?.plantSearchResults[indexPath.row]
        
        // common name
        resultCell.commonNameLabel.text = plantResult?.commonName?.capitalized ?? "No common name"
        
        // scientific name
        resultCell.scientificNameLabel.text = plantResult?.scientificName ?? "No scientific name"
        
        resultCell.spinner.startAnimating()
        // image
        // store returned UUID? for task for later
        let token = plantController?.loadImage(plantResult?.imageUrl) { result in
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
//                resultCell.plantImageView?.image = .logoImage
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
        fetchedScientificName = scientificName
        updateTextView()
    }
}
