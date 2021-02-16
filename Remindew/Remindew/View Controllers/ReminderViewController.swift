//
//  ReminderViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 1/2/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit

protocol ReminderDelegate {
    
    /// notify DetailViewController to update table view when reminder is added or updated
    func didAddOrUpdateReminder()
}

class ReminderViewController: UIViewController {

    // MARK: - Properties
    
    /// Holds all other views,
    let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 15
        return contentView
    }()
    
    /// Last Date (Action) was performed Label
    let lastDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Add New Reminder", comment: "title for add reminder screen")
        label.textColor = .mixedBlueGreen
        label.backgroundColor = .customCellColor
        label.textAlignment = .left
        label.numberOfLines = 1
        label.contentMode = .bottom
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    /// Save button to save changes and dismiss view controller
    let saveButton: UIButton = {
        let tempButton = UIButton(type: .system) // .system
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        tempButton.backgroundColor = .clear
        tempButton.tintColor = .mixedBlueGreen
        tempButton.setTitle(NSLocalizedString("Save", comment: "Done button"), for: .normal)
        tempButton.titleLabel?.font = .systemFont(ofSize: 18)
        tempButton.contentHorizontalAlignment = .right
        tempButton.layer.cornerRadius = 0
        return tempButton
    }()
    
    /// Displays customization options for Main Action ("Water", etc)
    let actionCustomizationView: CustomizationView = {
        let view = CustomizationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.plantNameLabel.isEnabled = true
        view.plantNameLabel.text = NSLocalizedString("Reminder", comment: "Name of reminder type")
        return view
    }()
    
    /// Date Picker for secondary reminder
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .mixedBlueGreen
        // TODO: change "selected" color to be lighter shade of gray "secondarySystemBackground"
//        picker.minimumDate = Date()
        // TODO: minimumTime? (shouldn't be able to pick a time earlier in the day)
        return picker
    }()
    
    /// Textfield for entering day frequency
    let frequencyTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.keyboardType = .numberPad
        textfield.text = "7"
        return textfield
    }()
    
    /// Label following frequencyTextfield that says "Days"
    let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("days", comment: "days label after frequency number")
        return label
    }()
    
    /// Switch to toggle isDisabled for Reminder
    let isEnabledSwitch: UISwitch = {
        let tempSwitch = UISwitch()
        tempSwitch.translatesAutoresizingMaskIntoConstraints = false
        tempSwitch.onTintColor = .mixedBlueGreen
        tempSwitch.isOn = true
        return tempSwitch
    }()
       
    /// Custom View that looks like Notifications banners
    let notificationBubble: NotificationView = {
        let view = NotificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Textview for any notes
    let notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Notes"
        textView.font = .systemFont(ofSize: 14)
        textView.layer.cornerRadius = 15
        textView.backgroundColor = .customComponentColor
        textView.contentMode = .left
        return textView
    }()
    
    /// Standard padding for left and right sides
    let standardMargin: CGFloat = 20.0
    
    /// Holds plantController that will be passed in to save plant with reminder
    var plantController: PlantController?
    
    /// Holds plant that will be passed in and displayed
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds reminder that will be passed in when clicking on a cell
    var reminder: Reminder? {
        didSet {
            updateViews()
        }
    }
    
    /// Tells DetailViewControlle to update its table view when a reminder is added or updated
    var reminderDelegate: ReminderDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        
        // pass in datePicker and isDisabledSwitch so their color can be updated too
        actionCustomizationView.datePicker = datePicker
        actionCustomizationView.notificationSwitch = isEnabledSwitch
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if reminder != nil {
            notesTextView.becomeFirstResponder()
        } else {
            actionCustomizationView.plantNameLabel.becomeFirstResponder()
        }
    }
        
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        print("Save button tapped")
            
        // We came from EDIT mode, so we can safely update the plant here (currently can only add/edit reminders to existing plants)
        if let plant = plant {
            
            // make sure reminder has an actionName
            guard let actionName = actionCustomizationView.plantNameLabel.text else {
                // TODO: Error alert for no name
                print("no name for action")
                return
            }
            
            // make sure frequency is a number and greater than 0
            guard let frequencyString = frequencyTextfield.text, !frequencyString.isEmpty, let frequency = Int16(frequencyString), frequency > 0 else {
                // TODO: Error alert for invalid or missing frequency number
                print("no text in frequency textfield")
                return
            }
            
            // TODO: unwrap title and message textfields and give default values instead of "" ?
            
            // EDIT Reminder
            if let existingReminder = reminder {
                
                plantController?.editReminder(reminder: existingReminder,
                                              actionName: actionName,
                                              alarmDate: datePicker.date,
                                              frequency: frequency,
                                              actionTitle: notificationBubble.reminderTitleTextfield.text ?? "",
                                              actionMessage: notificationBubble.reminderMessageTextfield.text ?? "",
                                              notes: notesTextView.text,
                                              isEnabled: isEnabledSwitch.isOn,
                                              colorIndex: Int16(actionCustomizationView.localColorsCount),
                                              iconIndex: Int16(actionCustomizationView.localIconCount))
            }
            
            // ADD Reminder
            else {
                plantController?.addNewReminderToPlant(plant: plant,
                                                       actionName: actionName,
                                                       alarmDate: datePicker.date,
                                                       frequency: frequency,
                                                       actionTitle: notificationBubble.reminderTitleTextfield.text ?? "",
                                                       actionMessage: notificationBubble.reminderMessageTextfield.text ?? "",
                                                       notes: notesTextView.text,
                                                       isEnabled: isEnabledSwitch.isOn,
                                                       colorIndex: Int16(actionCustomizationView.localColorsCount),
                                                       iconIndex: Int16(actionCustomizationView.localIconCount))
            }
        }
        
        // update table view in DetailViewController
        reminderDelegate?.didAddOrUpdateReminder()
        dismiss(animated: true, completion: nil)
    }
    
    private func setupSubviews() {
        
        // Content View
        view.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: standardMargin).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -standardMargin).isActive = true
        contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CGFloat(0.55)).isActive = true
        
        // Done/Save Button
        contentView.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: CGFloat(0.2)).isActive = true
        saveButton.heightAnchor.constraint(equalTo: saveButton.widthAnchor, multiplier: 0.5).isActive = true
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Last Date (Watered) Label
        contentView.addSubview(lastDateLabel)
        lastDateLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        lastDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lastDateLabel.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor).isActive = true
        lastDateLabel.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Main Action Customization View
        contentView.addSubview(actionCustomizationView)
        actionCustomizationView.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor).isActive = true
        actionCustomizationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        actionCustomizationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        actionCustomizationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Date Picker
        contentView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: actionCustomizationView.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Frequency TextField
        contentView.addSubview(frequencyTextfield)
        frequencyTextfield.topAnchor.constraint(equalTo: actionCustomizationView.bottomAnchor).isActive = true
        frequencyTextfield.leadingAnchor.constraint(equalTo: datePicker.trailingAnchor).isActive = true
        frequencyTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1).isActive = true
        frequencyTextfield.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor).isActive = true
        
        // Days Label
        contentView.addSubview(daysLabel)
        daysLabel.topAnchor.constraint(equalTo: actionCustomizationView.bottomAnchor).isActive = true
        daysLabel.leadingAnchor.constraint(equalTo: frequencyTextfield.trailingAnchor).isActive = true
        daysLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15).isActive = true
        daysLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor).isActive = true
        
        // isDisabled Switch
        contentView.addSubview(isEnabledSwitch)
        isEnabledSwitch.topAnchor.constraint(equalTo: actionCustomizationView.bottomAnchor).isActive = true
        isEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        isEnabledSwitch.widthAnchor.constraint(equalToConstant: 50).isActive = true
        isEnabledSwitch.heightAnchor.constraint(equalToConstant: 31).isActive = true
        isEnabledSwitch.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor).isActive = true
        
        // Notification Bubble
        contentView.addSubview(notificationBubble)
        notificationBubble.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4).isActive = true
        notificationBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notificationBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        notificationBubble.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Notes Textview
        contentView.addSubview(notesTextView)
        notesTextView.topAnchor.constraint(equalTo: notificationBubble.bottomAnchor, constant: 4).isActive = true
        notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        notesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    
    private func updateViews() {
        
        guard isViewLoaded else { return }
                
        // EDIT/DETAIL Mode
        if let plant = plant {
            print("reminder in edit mode = \(String(describing: plant.reminders))")

            
            let remindersArray = plant.reminders?.allObjects as! Array<Reminder>
            print("remindersArray = \(remindersArray)")
            
            // EDIT REMINDER WE CLICKED ON (from tableView cell)
            if let reminder = reminder {
                actionCustomizationView.plantNameLabel.text = reminder.actionName
                notificationBubble.reminderTitleTextfield.text = reminder.actionTitle
                notificationBubble.reminderMessageTextfield.text = reminder.actionMessage
                datePicker.date = reminder.alarmDate!// ?? Date()
                isEnabledSwitch.isOn = reminder.isEnabled
                frequencyTextfield.text = "\(reminder.frequency)"
                notesTextView.text = reminder.notes
                
                let reminderColor = UIColor.colorsArray[Int(reminder.colorIndex)]
                actionCustomizationView.localColorsCount = Int(reminder.colorIndex)
                actionCustomizationView.localIconCount = Int(reminder.iconIndex)
                isEnabledSwitch.onTintColor = reminderColor
                datePicker.tintColor = reminderColor

                // if reminder has been completed at least once, display lastDate
                if let lastDate = reminder.lastDate {
                    lastDateLabel.text = NSLocalizedString("Last: ", comment: "last time watered") + "\(DateFormatter.lastWateredDateFormatter.string(from: lastDate))"
                }
                
                // use dateCreated as a fall back if reminder hasn't been completed yet (new reminder)
                else {
                    lastDateLabel.text = NSLocalizedString("Made: ", comment: "date created label") +
                        "\(DateFormatter.lastWateredDateFormatter.string(from: reminder.dateCreated!))"
                }
            }
        }
    }
}
