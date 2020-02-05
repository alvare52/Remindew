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
    
    // TEST
    var fakePlant: FakePlant? {
        didSet {
            updateViews()
        }
    }
    // TEST
    
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
        updateViews()
    }
    
    func updateViews() {
        print("update views")
        guard isViewLoaded else {return}
        
        title = fakePlant?.nickname ?? "Add New Plant"
        nicknameTextField.text = fakePlant?.nickname ?? ""
        speciesTextField.text = fakePlant?.species ?? ""
        frequencySegment.selectedSegmentIndex = (fakePlant?.frequency ?? 1) - 1
        datePicker.date = fakePlant?.water_schedule ?? Date()
        if fakePlant != nil {
            plantButton.setTitle("Edit Plant", for: .normal)
            plantButton.backgroundColor = .systemBlue
            plantButton.performFlare()
        }
        else {
            plantButton.setTitle("Add Plant", for: .normal)
            plantButton.backgroundColor = .systemGreen
            plantButton.performFlare()
        }
    }
}
