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
    
    // MARK: - Actions
    
    @IBAction func waterPlantButtonTapped(_ sender: UIButton) {
        print("waterPlantButtonTapped")
        
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
            // if it DOES need to be watered, update needsWatering to false
            if existingPlant.needsWatering {
                userController?.updatePlantWithWatering(plant: existingPlant, needsWatering: false)
            }
            // does it need this?
//            else {
//                // if it does NOT need watering (already watered)
//                let dateString = dateFormatter2.string(from: existingPlant.lastDateWatered!)
//                waterPlantButton.setTitle("Last watered: \(dateString)", for: .normal)
//            }
            navigationController?.popViewController(animated: true)
        }
//
//        // If there is NO plant (ADD)
//        else {
//            waterPlantButton.setTitle("---", for: .normal)
//            // or hide button?
//        }
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
            // If there IS a plant, update (EDIT)
            if let existingPlant = plant {
                                
                userController?.update(nickname: nickname.capitalized,
                                       species: species.capitalized,
                                       water_schedule: waterDate ?? Date(),
                                       frequency: daySelectorOutlet.returnDaysSelected(),
                                       plant: existingPlant)
            }
                
            // If there is NO plant (ADD)
            else {
                userController?.createPlant(nickname: nickname.capitalized,
                                            species: species.capitalized,
                                            date: waterDate ?? Date(),
                                            frequency: daySelectorOutlet.returnDaysSelected())
            }
            
            navigationController?.popViewController(animated: true)
        }
        
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
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/d"
        return formatter
    }
    
    var dateFormatter2: DateFormatter {
        let formatter = DateFormatter()
//            formatter.dateFormat = "EEEE MMM d, h:mm a"
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        
        dateLabel.title = dateFormatter.string(from: Date())
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        
        // Hides Keyboard when tapping outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        nicknameTextField.borderStyle = .none
        speciesTextField.borderStyle = .none
        nicknameTextField.textColor = .darkGray
        speciesTextField.textColor = .darkGray
        
        nicknameTextField.delegate = self
        speciesTextField.delegate = self
        
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
    
    func updateViews() {
        
        guard isViewLoaded else {return}
        
        if let plant = plant {
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
                    waterPlantButton.setTitle("Last: \(dateString)", for: .normal)
                } else {
                    // Plant that HASN'T been watered before (brand new plant)
                    waterPlantButton.isHidden = true
                }
                waterPlantButton.isEnabled = false
            }
        }
            
        else {
            plantButton.setTitle("Add Plant", for: .normal)
            title = "Add New Plant"
            nicknameTextField.text = ""
            speciesTextField.text = ""
            datePicker.date = Date()
//            waterPlantButton.setTitle("---", for: .normal)
            waterPlantButton.isHidden = true
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
        textField.resignFirstResponder()
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
