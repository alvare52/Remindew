//
//  ReminderViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 1/2/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {

    // MARK: - Properties
    
    /// Holds plantController that will be passed in to save plant with reminder
    var plantController: PlantController?
    
    /// Holds plant that will be passed in and displayed
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupSubviews() {
        
    }
    
    
    private func updateViews() {
        
        guard isViewLoaded else { return }
        
        // EDIT/DETAIL Mode
        if let plant = plant {
//            let newReminder = Reminder(actionName: "Pesticide", alarmDate: Date(), frequency: Int16(7))
//            newReminder.actionMessage = "time to add pesticide to Leaf Erikson"
//            newReminder.actionTitle = "Pesticide Time"
//            plant.addToReminders(newReminder)
            
//            print("plant.reminders = \(plant.reminders?.allObjects ?? [])")
//            let reminders = plant.reminders as! Set<Reminder>
//            let reminder = reminders.first(where: {$0.actionName == "Pesticide"})
        }
        
        // ADD Mode
        else {
            
        }
    }
}
