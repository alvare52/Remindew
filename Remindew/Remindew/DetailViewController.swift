//
//  DetailViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var frequencySegment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var plantButton: UIButton!
    @IBOutlet weak var backButton: UINavigationItem!
    
    var userController: UserController?
    
    // TEST
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    // TEST
    
    @IBAction func plantButtonTapped(_ sender: UIButton) {
        
        if let nickname = nicknameTextField.text, let species = speciesTextField.text, !nickname.isEmpty, !species.isEmpty {
            // If there is a plant, update (detail)
            if let existingPlant = plant {
                userController?.update(nickname: nickname, species: species, water_schedule: datePicker.date, frequency: Int16(frequencySegment.selectedSegmentIndex + 1), plant: existingPlant)
            }
            // If there is NO plant (add)
            else {
                let newPlant = Plant(nickname: nickname, species: species, water_schedule: datePicker.date, frequency: Int16(frequencySegment.selectedSegmentIndex + 1))
                userController?.sendPlantToServer(plant: newPlant)
                
                
                do {
                    try CoreDataStack.shared.mainContext.save()
                } catch {
                    NSLog("Error saving managed object context: \(error)")
                }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField.autocorrectionType = .no
        speciesTextField.autocorrectionType = .no
        datePicker.minimumDate = Date()
        plantButton.layer.cornerRadius = 10.0
        updateViews()
    }
        
    func updateViews() {
        print("update views")
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
