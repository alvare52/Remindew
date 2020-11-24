//
//  DetailViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var frequencySegment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var plantButton: UIButton!
    @IBOutlet weak var backButton: UINavigationItem!
    
    @IBOutlet var cameraButtonLabel: UIBarButtonItem!
        
    // MARK: - Actions
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        print("CameraButton tapped")
    }
        
    @IBAction func plantButtonTapped(_ sender: UIButton) {
        
        if let nickname = nicknameTextField.text, let species = speciesTextField.text, !nickname.isEmpty, !species.isEmpty {
            
            // If there IS a plant, update (EDIT)
            if let existingPlant = plant {
                userController?.update(nickname: nickname.capitalized,
                                       species: species.capitalized,
                                       water_schedule: datePicker.date,
                                       frequency: Int16(frequencySegment.selectedSegmentIndex + 1),
                                       plant: existingPlant)
            }
                
            // If there is NO plant (ADD)
            else {
                userController?.createPlant(nickname: nickname.capitalized,
                                            species: species.capitalized,
                                            date: datePicker.date,
                                            frequency: Int16(frequencySegment.selectedSegmentIndex + 1))
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
        datePicker.minimumDate = Date()
        updateViews()
    }
        
    func updateViews() {
        
        guard isViewLoaded else {return}
        
        title = plant?.nickname ?? "Add New Plant"
        nicknameTextField.text = plant?.nickname ?? ""
        speciesTextField.text = plant?.species ?? ""
        frequencySegment.selectedSegmentIndex = Int((plant?.frequency ?? 1) - 1)
        datePicker.date = plant?.water_schedule ?? Date()
        if plant != nil {
            plantButton.setTitle("Edit Plant", for: .normal)
            plantButton.performFlare()
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
