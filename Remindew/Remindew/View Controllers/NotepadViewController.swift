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
        label.backgroundColor = .clear
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
    
    let scientificNameTextfield: UITextField = {
        let scienceTextfield = UITextField()
        scienceTextfield.translatesAutoresizingMaskIntoConstraints = false
        scienceTextfield.font = .italicSystemFont(ofSize: 17)
        scienceTextfield.placeholder = "Scientific name"
        scienceTextfield.backgroundColor = .clear
        scienceTextfield.autocorrectionType = .no
        scienceTextfield.contentVerticalAlignment = .bottom
        scienceTextfield.tintColor = .mixedBlueGreen
        return scienceTextfield
    }()
    
    /// Location textfield
    let locationTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = NSLocalizedString("Location", comment: "where is the plant located")
        textfield.contentVerticalAlignment = .bottom
        textfield.tintColor = .mixedBlueGreen
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
        textfield.placeholder = NSLocalizedString("Action", comment: "main action for plant")
        textfield.text = NSLocalizedString("Water", comment: "water, default main action")
        textfield.contentVerticalAlignment = .bottom
        textfield.textColor = .waterBlue
        return textfield
    }()
    
    /// Notification bubble view (88 pts height), holds title and message textfields
    let notificationView: NotificationView = {
        let view = NotificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Thin gray line thats under scientificNameTextfield
    let scientificLine: UIView = {
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
        textView.backgroundColor = .customComponentColor
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
    
    /// Standard padding for left and right sides
    let standardMargin: CGFloat = 20.0
    
    /// Updates all views when plant is passed in
    private func updateViews() {
        print("updateViews")
        guard isViewLoaded else { return }
        
        // EDIT/DETAIL Mode
        if let plant = plant {
            scientificNameTextfield.text = plant.scientificName
            notificationView.reminderTitleTextfield.text = plant.mainTitle
            notificationView.reminderMessageTextfield.text = plant.mainMessage
            actionTextfield.text = plant.mainAction
            locationTextfield.text = plant.location
            notesTextView.text = plant.notes
            if let lastDate = plant.lastDateWatered {
                lastDateLabel.text = NSLocalizedString("Last: ", comment: "last time watered") + "\(DateFormatter.lastWateredDateFormatter.string(from: lastDate))"
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
                              mainTitle: notificationView.reminderTitleTextfield.text ?? "",
                              mainMessage: notificationView.reminderMessageTextfield.text ?? "",
                              mainAction: actionTextfield.text ?? NSLocalizedString("Water", comment: "water, default main action"),
                              location: locationTextfield.text?.capitalized ?? "",
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
        
        // Action Name ("Water")
        contentView.addSubview(actionTextfield)
        actionTextfield.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor).isActive = true
        actionTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        actionTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
        actionTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Location Textfield
        contentView.addSubview(locationTextfield)
        locationTextfield.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor).isActive = true
        locationTextfield.leadingAnchor.constraint(equalTo: actionTextfield.trailingAnchor).isActive = true
        locationTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
        locationTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Location Line
        contentView.addSubview(locationLine)
        locationLine.topAnchor.constraint(equalTo: locationTextfield.bottomAnchor, constant: 4).isActive = true
        locationLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        locationLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        locationLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        locationLine.backgroundColor = .lightGray
        
        // Scientific Name Textfield
        contentView.addSubview(scientificNameTextfield)
        scientificNameTextfield.topAnchor.constraint(equalTo: locationLine.bottomAnchor).isActive = true
        scientificNameTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scientificNameTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scientificNameTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Scientific Line
        contentView.addSubview(scientificLine)
        scientificLine.topAnchor.constraint(equalTo: scientificNameTextfield.bottomAnchor, constant: 4).isActive = true
        scientificLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scientificLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scientificLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        scientificLine.backgroundColor = .lightGray
                
        // Notification View
        contentView.addSubview(notificationView)
        notificationView.topAnchor.constraint(equalTo: scientificLine.bottomAnchor, constant: 4).isActive = true
        notificationView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        notificationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notificationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
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
