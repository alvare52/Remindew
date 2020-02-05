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
    
    @IBAction func plantButtonTapped(_ sender: UIButton) {
        
        // TEST
        guard let nickname = nicknameTextField.text, let species = speciesTextField.text else {return}
        let createdPlant = FakePlant(nickname: nickname, species: species, water_schedule: datePicker.date, last_watered: nil, frequency: frequencySegment.selectedSegmentIndex + 1, image_url: nil, id: 8)
        testPlants.append(createdPlant)
        // TEST
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        plantButton.layer.cornerRadius = 5.0
    }
}
