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
        label.text = "Brand New Plant"
        label.textColor = .waterBlue
        label.backgroundColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.contentMode = .bottom
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    /// Save button to save changes and dismiss view controller
    let saveButton: UIButton = {
        let tempButton = UIButton(type: .system) // .system
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        tempButton.backgroundColor = .clear
        tempButton.tintColor = .mixedBlueGreen
        tempButton.setTitle("Save", for: .normal)
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
        return view
    }()
    
    /// Date Picker for secondary reminder
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .mixedBlueGreen
        picker.minimumDate = Date()
//        picker.backgroundColor = .orange
        return picker
    }()
    
    /// Textfield for entering day frequency
    let frequencyTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
//        textfield.backgroundColor = .blue
        textfield.keyboardType = .numberPad
        textfield.text = "7"
        return textfield
    }()
    
    /// Label following frequencyTextfield that says "Days"
    let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("days", comment: "days label after frequency number")
//        label.backgroundColor = .lightGray
        return label
    }()
    
    /// Switch to toggle isDisabled for Reminder
    let isDisabledSwitch: UISwitch = {
        let tempSwitch = UISwitch()
        tempSwitch.translatesAutoresizingMaskIntoConstraints = false
        tempSwitch.onTintColor = .mixedBlueGreen
        tempSwitch.isOn = true
//        tempSwitch.backgroundColor = .yellow
        return tempSwitch
    }()
    
    /// Notification bubble view (88 pts height), holds title and message textfields
    let notificationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .darkGray
        return view
    }()
    
    /// Displays small app icon image in top left corner of notification view
    let smallIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = .white
        imageView.image = UIImage.smallAppIconImage
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// Displays name of app in notification view
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "REMINDEW"
        return label
    }()
    
    /// Displays how many minutes ago notification was sent (purely visual)
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .light)
//        label.backgroundColor = .orange
        label.text = "16m ago"
        label.textAlignment = .right
        return label
    }()
    
    let reminderTitleTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.text = "Reminder Title"
        textfield.backgroundColor = .clear
        textfield.textColor = .white
        textfield.font = .systemFont(ofSize: 14, weight: .semibold)
        textfield.contentVerticalAlignment = .bottom
        textfield.tintColor = .white
        return textfield
    }()
    
    let reminderMessageTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.text = "Reminder Message"
        textfield.font = .systemFont(ofSize: 14)
        textfield.textColor = .white
        textfield.backgroundColor = .clear
        textfield.tintColor = .white
        textfield.contentVerticalAlignment = .top
        return textfield
    }()
    
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
        textView.backgroundColor = .lightModeBackgroundGray
        textView.contentMode = .left
        return textView
    }()
    
    /// Last Watered Label
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd/yy, h:mm a"
        return formatter
    }
    
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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        print("Save button tapped")
    
        // We came from EDIT mode, so we can safely update the plant here
        if let plant = plant {
            // if plant has no reminders yet (came from "empty" cell)
            
            // if editing a reminder we selected
            guard let actionName = actionCustomizationView.plantNameLabel.text else {
                print("no name for action")
                return
            }
            guard let frequencyString = frequencyTextfield.text, !frequencyString.isEmpty, let frequency = Int16(frequencyString) else {
                print("no text in frequency textfield")
                return
            }
            
            let newReminder = Reminder(actionName: actionName,
                                       alarmDate: datePicker.date,
                                       frequency: frequency)
            newReminder.actionTitle = notificationBubble.reminderTitleTextfield.text
            newReminder.actionMessage = notificationBubble.reminderMessageTextfield.text
            newReminder.notes = notesTextView.text
            newReminder.isDisabled = !isDisabledSwitch.isOn
            plantController?.addReminderToPlant(reminder: newReminder, plant: plant)
//            let remindersArray = plant.reminders?.allObjects as! Array<Reminder>
//            print("remindersArray = \(remindersArray)")
        }
        // if we DON'T have a plant
        else {

        }
        
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
        contentView.addSubview(isDisabledSwitch)
        isDisabledSwitch.topAnchor.constraint(equalTo: actionCustomizationView.bottomAnchor).isActive = true
        isDisabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        isDisabledSwitch.widthAnchor.constraint(equalToConstant: 50).isActive = true
        isDisabledSwitch.heightAnchor.constraint(equalToConstant: 31).isActive = true
        isDisabledSwitch.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor).isActive = true
        
//        // Main Action Customization View
//        contentView.addSubview(actionCustomizationView)
//        actionCustomizationView.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor).isActive = true
//        actionCustomizationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
//        actionCustomizationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
//        actionCustomizationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Notification Bubble
        contentView.addSubview(notificationBubble)
        notificationBubble.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4).isActive = true
        notificationBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notificationBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        notificationBubble.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        // Notification View
//        contentView.addSubview(notificationView)
//        notificationView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4).isActive = true
//        notificationView.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        notificationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
//        notificationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
//
//        // Small Icon ImageView
//        notificationView.addSubview(smallIconImageView)
//        smallIconImageView.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10).isActive = true
//        smallIconImageView.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor, constant: 12).isActive = true
//        smallIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        smallIconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
//
//        // App Name Label
//        notificationView.addSubview(appNameLabel)
//        appNameLabel.centerYAnchor.constraint(equalTo: smallIconImageView.centerYAnchor).isActive = true
//        appNameLabel.leadingAnchor.constraint(equalTo: smallIconImageView.trailingAnchor, constant: 8).isActive = true
//        appNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
//
//        // Time Label
//        notificationView.addSubview(timeLabel)
//        timeLabel.centerYAnchor.constraint(equalTo: smallIconImageView.centerYAnchor).isActive = true
//        timeLabel.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor, constant: -16).isActive = true
//        timeLabel.widthAnchor.constraint(equalTo: saveButton.widthAnchor).isActive = true
//
//        // Reminder Title ("Time to water your plant") Textfield
//        notificationView.addSubview(reminderTitleTextfield)
//        reminderTitleTextfield.topAnchor.constraint(equalTo: smallIconImageView.bottomAnchor, constant: 4).isActive = true
//        reminderTitleTextfield.leadingAnchor.constraint(equalTo: smallIconImageView.leadingAnchor).isActive = true
//        reminderTitleTextfield.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor,
//                                                         constant: -16).isActive = true
//
//        // Reminder Message Textfield
//        notificationView.addSubview(reminderMessageTextfield)
//        reminderMessageTextfield.topAnchor.constraint(equalTo: reminderTitleTextfield.bottomAnchor).isActive = true
//        reminderMessageTextfield.leadingAnchor.constraint(equalTo: reminderTitleTextfield.leadingAnchor).isActive = true
//        reminderMessageTextfield.trailingAnchor.constraint(equalTo: reminderTitleTextfield.trailingAnchor).isActive = true
        
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
            print("reminder in edit mode = \(plant.reminders)")

            
            let remindersArray = plant.reminders?.allObjects as! Array<Reminder>
            print("remindersArray = \(remindersArray)")
            
            // EDIT reminder
            if let reminder = reminder {
                actionCustomizationView.plantNameLabel.text = reminder.actionName
                notificationBubble.reminderTitleTextfield.text = reminder.actionTitle
                notificationBubble.reminderMessageTextfield.text = reminder.actionMessage
                datePicker.date = reminder.alarmDate ?? Date()
                isDisabledSwitch.isOn = reminder.isDisabled
                frequencyTextfield.text = "\(reminder.frequency)"
                if let lastDate = reminder.lastDate {
                    lastDateLabel.text = NSLocalizedString("Last: ", comment: "last time watered") + "\(dateFormatter.string(from: lastDate))"
                } else {
                    lastDateLabel.text = "Brand New Plant"
                }
            }
            
            // ADD reminder
            else {
                
            }
            
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