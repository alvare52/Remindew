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
    @IBOutlet weak var frequencySegment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var plantButton: UIButton!
    @IBOutlet weak var backButton: UINavigationItem!
    
    @IBOutlet var cameraButtonLabel: UIBarButtonItem!
        
    @IBOutlet var daySelectorOutlet: DaySelectionView!
    // MARK: - Actions
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        print("CameraButton tapped")
        AudioServicesPlaySystemSound(SystemSoundID(1105))
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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Hides Keyboard when tapping outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        nicknameTextField.delegate = self
        speciesTextField.delegate = self
        plantButton.applyGradient(colors: [UIColor.darkBlueGreen.cgColor, UIColor.lightBlueGreen.cgColor])
        nicknameTextField.autocorrectionType = .no
        speciesTextField.autocorrectionType = .no
        // NEW
//        datePicker.minimumDate = Date()
        // NEW
        // Should maximumDate be untle the end of the current day?
        datePicker.datePickerMode = .time
        updateViews()
    }
        
    func updateViews() {
        
        guard isViewLoaded else {return}
        
        title = plant?.nickname ?? "Add New Plant"
        nicknameTextField.text = plant?.nickname ?? ""
        speciesTextField.text = plant?.species ?? ""
//        frequencySegment.selectedSegmentIndex = Int((plant?.frequency ?? 1) - 1)
        frequencySegment.selectedSegmentIndex = Int((plant?.frequency![0] ?? 1) - 1)
        
        datePicker.date = plant?.water_schedule ?? Date()
        if plant != nil {
            plantButton.setTitle("Edit Plant", for: .normal)
            plantButton.performFlare()
            daySelectorOutlet.selectDays((plant?.frequency)!)
        }
        else {
            plantButton.setTitle("Add Plant", for: .normal)
            plantButton.performFlare()
        }
    }
}

extension DetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return")
        textField.resignFirstResponder()
        return true
    }
}
