//
//  NotepadViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/26/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

// Delegate 1
protocol NotepadDelegate {
    func didMakeNotepad(notepad: NotePad)
    func didMakeNotepadWithPlant(notepad: NotePad, plant: Plant)
}

class NotepadViewController: UIViewController {

    // MARK: - Properties
    
    // Delegate 2
    var notepadDelegate: NotepadDelegate?
    
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
        label.font = .systemFont(ofSize: 15)
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
    
    let scientificNameTextfield: UITextField = {
        let scienceTextfield = UITextField()
        scienceTextfield.translatesAutoresizingMaskIntoConstraints = false
        scienceTextfield.font = .italicSystemFont(ofSize: 17)
        scienceTextfield.placeholder = "Scientific name"
        scienceTextfield.backgroundColor = .white
        scienceTextfield.contentVerticalAlignment = .bottom
        return scienceTextfield
    }()
    
    /// Location textfield
    let locationTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Location"
        textfield.contentVerticalAlignment = .bottom
        return textfield
    }()
    
    /// Thin gray line thats under locationTextfield
    let locationLine: UIView = {
        let lineBreak = UIView()
        lineBreak.translatesAutoresizingMaskIntoConstraints = false
        return lineBreak
    }()
    
    /// Action  textfield
    let actionTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Water"
        textfield.text = NSLocalizedString("Water", comment: "water, default main action")
        textfield.contentVerticalAlignment = .bottom
        textfield.textColor = .waterBlue
        return textfield
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
        textfield.placeholder = "Reminder Title"
        textfield.text = NSLocalizedString("Time to water your plant!", comment: "Title for notification")
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
        textfield.placeholder = "Reminder Message"
        textfield.text = NSLocalizedString("One of your plants needs water", comment: "Message for notification")
        textfield.font = .systemFont(ofSize: 14)
        textfield.textColor = .white
        textfield.backgroundColor = .clear
        textfield.tintColor = .white
        textfield.contentVerticalAlignment = .top
        return textfield
    }()
        
    /// Thin gray line thats under scientificNameTextfield
    let scientificLine: UIView = {
        let lineBreak = UIView()
        lineBreak.translatesAutoresizingMaskIntoConstraints = false
        return lineBreak
    }()
    
    /// Thin gray line thats under reminderTitleTextfield
    let titleLine: UIView = {
        let lineBreak = UIView()
        lineBreak.translatesAutoresizingMaskIntoConstraints = false
        return lineBreak
    }()
    
    /// Thin gray line thats under reminderMessageTextfield
    let messageLine: UIView = {
        let lineBreak = UIView()
        lineBreak.translatesAutoresizingMaskIntoConstraints = false
        return lineBreak
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
    
    var plantController: PlantController?
    
    /// Holds plant that will be passed in and displayed
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Last Watered Label
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd/yy, h:mm a"
        return formatter
    }
    
    /// Standard padding for left and right sides
    let standardMargin: CGFloat = 20.0
    
    /// Updates all views when plant is passed in
    private func updateViews() {
        print("updateViews")
        guard isViewLoaded else { return }
        
        // EDIT/DETAIL Mode
        if let plant = plant {
            scientificNameTextfield.text = plant.scientificName
            reminderTitleTextfield.text = plant.mainTitle
            reminderMessageTextfield.text = plant.mainMessage
            actionTextfield.text = plant.mainAction
            locationTextfield.text = plant.location
            notesTextView.text = plant.notes
            if let lastDate = plant.lastDateWatered {
                lastDateLabel.text = NSLocalizedString("Last: ", comment: "last time watered") + "\(dateFormatter.string(from: lastDate))"
            } else {
                lastDateLabel.text = "Brand New Plant"
            }
        }
        
        // ADD Mode
        else {
            actionTextfield.text = NSLocalizedString("Water", comment: "water, default main action")
        }
    }
    
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        print("Save button tapped")
        
        let notepad = NotePad(notes: notesTextView.text,
                              mainTitle: reminderTitleTextfield.text ?? "",
                              mainMessage: reminderMessageTextfield.text ?? "",
                              mainAction: actionTextfield.text ?? NSLocalizedString("Water", comment: "water, default main action"),
                              location: locationTextfield.text ?? "",
                              scientificName: scientificNameTextfield.text ?? "")
        
       
        
        // We came from EDIT mode, so we can safely update the plant here
        if let plant = plant {
            // save plant, so we pass back an updated one (removing existing notifications MIGHT slow this down)
            plantController?.updateInNotepad(notepad: notepad, plant: plant)
            // pass back our notepad and hopefully updated plant so it triggers didSet -> updateViews() -> update Action button
            notepadDelegate?.didMakeNotepadWithPlant(notepad: notepad, plant: plant)
            dismiss(animated: true, completion: nil)
            return
        }
        // if we DON'T have a plant
        else {
            // Delegate 3
            // pass back notepad we have now
            notepadDelegate?.didMakeNotepad(notepad: notepad)
            dismiss(animated: true, completion: nil)
            return
        }
        
    }
    
    // MARK: - View Life Cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notesTextView.becomeFirstResponder()
    }
    
    // TODO: alert if user tries to leave without saving?
    /// Present alert if user tries to leave without saving?
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    /// Lays out all views needed
    private func setupSubViews() {
        
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
        
        // Scientific Name Textfield
        contentView.addSubview(scientificNameTextfield)
        scientificNameTextfield.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor).isActive = true
        scientificNameTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scientificNameTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scientificNameTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Scientific Line
        contentView.addSubview(scientificLine)
        scientificLine.topAnchor.constraint(equalTo: scientificNameTextfield.bottomAnchor, constant: 2).isActive = true
        scientificLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scientificLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scientificLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        scientificLine.backgroundColor = .lightGray
                
        // Location Textfield
        contentView.addSubview(locationTextfield)
        locationTextfield.topAnchor.constraint(equalTo: scientificLine.bottomAnchor).isActive = true
        locationTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        locationTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        locationTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Location Line
        contentView.addSubview(locationLine)
        locationLine.topAnchor.constraint(equalTo: locationTextfield.bottomAnchor, constant: 2).isActive = true
        locationLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        locationLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        locationLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        locationLine.backgroundColor = .lightGray
        
        // Action Name ("Water")
        contentView.addSubview(actionTextfield)
        actionTextfield.topAnchor.constraint(equalTo: scientificLine.bottomAnchor).isActive = true
        actionTextfield.leadingAnchor.constraint(equalTo: locationTextfield.trailingAnchor).isActive = true
        actionTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        actionTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Notification View
        contentView.addSubview(notificationView)
        notificationView.topAnchor.constraint(equalTo: locationLine.bottomAnchor, constant: 4).isActive = true
        notificationView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        notificationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notificationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        // Small Icon ImageView
        notificationView.addSubview(smallIconImageView)
        smallIconImageView.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10).isActive = true
        smallIconImageView.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor, constant: 12).isActive = true
        smallIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        smallIconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        // App Name Label
        notificationView.addSubview(appNameLabel)
        appNameLabel.centerYAnchor.constraint(equalTo: smallIconImageView.centerYAnchor).isActive = true
        appNameLabel.leadingAnchor.constraint(equalTo: smallIconImageView.trailingAnchor, constant: 8).isActive = true
        appNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Time Label
        notificationView.addSubview(timeLabel)
        timeLabel.centerYAnchor.constraint(equalTo: smallIconImageView.centerYAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor, constant: -16).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: saveButton.widthAnchor).isActive = true
        
        // Reminder Title ("Time to water your plant") Textfield
        notificationView.addSubview(reminderTitleTextfield)
        reminderTitleTextfield.topAnchor.constraint(equalTo: smallIconImageView.bottomAnchor, constant: 4).isActive = true
        reminderTitleTextfield.leadingAnchor.constraint(equalTo: smallIconImageView.leadingAnchor).isActive = true
        reminderTitleTextfield.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor,
                                                         constant: -16).isActive = true
        
        // Reminder Message Textfield
        notificationView.addSubview(reminderMessageTextfield)
        reminderMessageTextfield.topAnchor.constraint(equalTo: reminderTitleTextfield.bottomAnchor).isActive = true
        reminderMessageTextfield.leadingAnchor.constraint(equalTo: reminderTitleTextfield.leadingAnchor).isActive = true
        reminderMessageTextfield.trailingAnchor.constraint(equalTo: reminderTitleTextfield.trailingAnchor).isActive = true
        
        // Notes Textview
        contentView.addSubview(notesTextView)
        notesTextView.topAnchor.constraint(equalTo: notificationView.bottomAnchor, constant: 4).isActive = true
        notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        notesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

struct NotePad {
    var notes: String = ""
    var mainTitle: String = NSLocalizedString("Time to water your plant!", comment: "Title for notification")
    var mainMessage: String = NSLocalizedString("One of your plants needs water", comment: "Message for notification")
    var mainAction: String = NSLocalizedString("Water", comment: "water, default main action")
    var location: String = ""
    var scientificName: String = ""
}
