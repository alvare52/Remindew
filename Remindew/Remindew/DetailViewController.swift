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
    
    // MARK: - Actions
    
    @IBAction func waterPlantButtonTapped(_ sender: UIButton) {
        print("waterPlantButtonTapped")
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
            // if it DOES need to be watered, update needsWatering to false
            if existingPlant.needsWatering {
                userController?.updatePlantWithWatering(plant: existingPlant, needsWatering: false)
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
        
        
        let daysAreSelected: Bool = daySelectorOutlet.returnDaysSelected().count > 0
        
        if let nickname = nicknameTextField.text, let species = speciesTextField.text, !nickname.isEmpty, !species.isEmpty, daysAreSelected {
            
            // Doesn't really work here
//            let waterDate = userController?.returnWateringSchedule(plantDate: datePicker.date,
//                                                                   days: daySelectorOutlet.returnDaysSelected())
            let waterDate = userController?.createDateFromTimeAndDay(days: daySelectorOutlet.returnDaysSelected(),
                                                                     time: datePicker.date)
            
            // if there's no image, this is the default one (which will be removed if you try to save it again)
            var imageToSave = UIImage(named: "plantslogoclear1024x1024")!
            // replace image if there's one in the imageView
            if let image = imageView.image {
                print("Image in image view!")
                let scaledImage = userController?.resizeImage(image: image)
                imageToSave = scaledImage!
            }
            
            // If there IS a plant, update (EDIT)
            if let existingPlant = plant {
                                
                userController?.update(nickname: nickname.capitalized,
                                       species: species.capitalized,
                                       water_schedule: waterDate ?? Date(),
                                       frequency: daySelectorOutlet.returnDaysSelected(),
                                       plant: existingPlant)
                // save image
                let imageName = "userPlant\(existingPlant.identifier!)"
                userController?.saveImage(imageName: imageName, image: imageToSave)
            }
                
            // If there is NO plant (ADD)
            else {
                let plant = userController?.createPlant(nickname: nickname.capitalized,
                                            species: species.capitalized,
                                            date: waterDate ?? Date(),
                                            frequency: daySelectorOutlet.returnDaysSelected())
                // save image
                let imageName = "userPlant\(plant!.identifier!)"
                userController?.saveImage(imageName: imageName, image: imageToSave)
            }
            
            navigationController?.popViewController(animated: true)
        }
        
        // Missing something in one of the fields, give better error later
        else {
            let alertController = UIAlertController(title: "Invalid Field", message: "Please fill in all fields", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Properties
    
    var userController: PlantController?
    
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Nav bar date: Sunday 11/29
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
        
        // setting to false limits line to 2
//        textView.isScrollEnabled = false
        
        resultsTableView.backgroundView = spinner
        spinner.backgroundColor = .black
        spinner.color = .leafGreen
        
        // only show it after searching, then hide after choosing plant?
//        resultsTableView.isHidden = true
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
//        imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        
        dateLabel.title = dateFormatter.string(from: Date())
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        
        // Hides Keyboard when tapping outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        // so you can still click on the table view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        nicknameTextField.borderStyle = .none
        nicknameTextField.textColor = .darkGray
        nicknameTextField.delegate = self
        
        speciesTextField.borderStyle = .none
        speciesTextField.delegate = self
        speciesTextField.textColor = .darkGray
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
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // if the view appears and there's no text, auto "click" into first textfield
        if nicknameTextField.text == "" {
            nicknameTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // reset array
        userController?.plantSearchResults = []
    }
    
    func updateViews() {
        
        guard isViewLoaded else {return}
        
        // DETAIL/EDIT MODE
        if let plant = plant {
            
            // try to load saved image
            if let image = userController?.loadImageFromDiskWith(fileName: "userPlant\(plant.identifier!)") {
                imageView.image = image
            } else {
//                imageView.image = UIImage()
            }
            
            plantButton.setTitle("Edit Plant", for: .normal)
            let name = plant.nickname!
            let xAWeek = "\(plant.frequency!.count)x a week"
            title = "\(name) - \(xAWeek)"
            nicknameTextField.text = plant.nickname
            speciesTextField.text = plant.species
            datePicker.date = plant.water_schedule!
            daySelectorOutlet.selectDays((plant.frequency)!)
            
            waterPlantButton.isHidden = false
            if plant.needsWatering {
                waterPlantButton.setTitle("Water Plant", for: .normal)
                waterPlantButton.isEnabled = true
            } else {
                // Plant that has been watered before
                if let lastWatered = plant.lastDateWatered {
                    let dateString = dateFormatter2.string(from: lastWatered)
                    // replace this with scientific name from API call later
                    let scientificName = "Narcissus pseudonarcissus"
                    textView.text = "Last Watered:\n\(dateString)\n\(scientificName)"
//                    waterPlantButton.setTitle("Last: \(dateString)", for: .normal)
                } else {
                    // Plant that HASN'T been watered before (brand new plant)
//                    waterPlantButton.isHidden = true
                }
                waterPlantButton.isHidden = true
                waterPlantButton.isEnabled = false
            }
        }
         
        // ADD MODE
        else {
            plantButton.setTitle("Add Plant", for: .normal)
            title = "Add New Plant"
            nicknameTextField.text = ""
            speciesTextField.text = ""
            datePicker.date = Date()
//            waterPlantButton.setTitle("---", for: .normal)
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
        print("Return")
        if textField == speciesTextField {
            print("Return inside speciesTextfield")
            
            // get temp token first
//            userController?.signToken(completion: { (error) in
//                if let error = error {
//                    print("Error in signToken in detail VC: \(error)")
//                }
//                DispatchQueue.main.async {
//                    print("Success in signToken in detail VC")
//                    print("tempToken now \(self.userController?.tempToken)")
//                }
//            })
            guard let term = speciesTextField.text, !term.isEmpty else { return true }
            textField.resignFirstResponder()
            spinner.startAnimating()
            // Do search here
            userController?.searchPlantSpecies(term, completion: { (error) in
                if let error = error {
                    print("Error with searchPlantSpeciese in detail VC \(error)")
                    self.spinner.stopAnimating()
                }

                DispatchQueue.main.async {
                    print("Success with searchPlantSpecies in detail VC")
                    // pop up table VC with results?
                    self.resultsTableView.reloadData()
                    self.spinner.stopAnimating()
                }

            })
        }
//        textField.resignFirstResponder()
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
        return (userController?.plantSearchResults.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cast as a custom tableview cell (after I make one)
        let resultCell = resultsTableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath)
        let plantResult = userController?.plantSearchResults[indexPath.row]
        resultCell.textLabel?.text = plantResult?.commonName ?? "No Common Name"
        resultCell.detailTextLabel?.text = plantResult?.scientificName ?? "No Scientific Name"
        
//        userController?.fetchImage(with: plantResult?.imageUrl, completion: { (image) in
//            DispatchQueue.main.async {
//                resultCell.imageView?.image = image
//            }
//        })
        
        return resultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Hint", message: "You have selected row \(indexPath.row).", preferredStyle: .alert)
             
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
             
        alertController.addAction(alertAction)
             
        present(alertController, animated: true, completion: nil)
    }
}
