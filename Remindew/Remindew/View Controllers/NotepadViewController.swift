//
//  NotepadViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/26/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

/// Delegate protocol that lets DetailViewController when a Notepad has been made with or without a Plant
protocol NotepadDelegate {
    func didMakeNotepad(notepad: NotePad)
    func didMakeNotepadWithPlant(notepad: NotePad, plant: Plant)
}

class NotepadViewController: UIViewController {

    // MARK: - Properties
    
    /// Delegate coming from DetailViewController
    var notepadDelegate: NotepadDelegate?
    
    /// Holds all other views,
    let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .customDetailBackgroundColor
        return contentView
    }()
    
    /// Last Date (Action) was performed Label
    let lastDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Brand New Plant", comment: "plant that hasn't been watered yet")
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
        let tempButton = UIButton(type: .system)
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        tempButton.backgroundColor = .clear
        tempButton.tintColor = .mixedBlueGreen
        tempButton.setTitle(NSLocalizedString("Save", comment: "Done button"), for: .normal)
        tempButton.titleLabel?.font = .systemFont(ofSize: 18)
        tempButton.contentHorizontalAlignment = .right
        return tempButton
    }()
    
    /// Custom view that holds action, location, and scientificName textfield
    let plantDetailsView: PlantDetailsView = {
        let view = PlantDetailsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Notification bubble view (88 pts height), holds title and message textfields
    let notificationView: NotificationView = {
        let view = NotificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Textview for any notes
    let notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = NSLocalizedString("Notes", comment: "placeholder for notesTextView")
        textView.font = .systemFont(ofSize: 14)
        textView.layer.cornerRadius = 15
        textView.tintColor = .mixedBlueGreen
        textView.backgroundColor = .customComponentColor
        textView.contentMode = .left
        return textView
    }()
    
    /// PlantController we received from DetailViewController
    var plantController: PlantController?
    
    /// Holds plant that will be passed in and displayed
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds in nicknameTextfield.text, if it contains something
    var passedInNickname: String?
    
    /// Standard padding for left and right sides (20pts)
    let standardMargin: CGFloat = 20.0
    
    // MARK: - Actions
    
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        
        let locationString = plantDetailsView.locationTextfield.text?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var title = String.defaultTitleString()
        if let customTitle = notificationView.reminderTitleTextfield.text, notificationView.reminderTitleTextfield.text != "" {
            print("customTitle = \(customTitle)")
            title = customTitle
        }
    
        var action = plantDetailsView.actionTextfield.text ?? .waterLocalizedString
        action = action == "" ? .waterLocalizedString : action
        
        var name = String.defaultPlantNameLocalizedString
        if let customPassedInNickname = passedInNickname, !customPassedInNickname.isEmpty {
            print("customPassedInNickname = \(customPassedInNickname)")
            name = customPassedInNickname
        }
        if let customNickname = plant?.nickname {
            print("customNickname = \(customNickname)")
            name = customNickname
        }
        
//        let name = plant == nil ? .defaultPlantNameLocalizedString : plant!.nickname!
        
        var message = String.defaultMessageString(name: name, action: action)
        if let customMessage = notificationView.reminderMessageTextfield.text, notificationView.reminderMessageTextfield.text != "" {
            print("customMessage = \(customMessage)")
            message = customMessage
        }
        
        let notepad = NotePad(notes: notesTextView.text,
                              mainTitle: title,
                              mainMessage: message,
                              mainAction: action,
                              location: locationString,
                              scientificName: plantDetailsView.scientificNameTextfield.text ?? "")
        
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
    
    /// Updates all views when plant is passed in
    private func updateViews() {
        
        guard isViewLoaded else { return }
        
        // EDIT/DETAIL Mode
        if let plant = plant {
            plantDetailsView.scientificNameTextfield.text = plant.scientificName
            notificationView.reminderTitleTextfield.text = plant.mainTitle
            notificationView.reminderMessageTextfield.text = plant.mainMessage
            plantDetailsView.actionTextfield.text = plant.mainAction
            plantDetailsView.locationTextfield.text = plant.location
            lastDateLabel.textColor = UIColor.colorsArray[Int(plant.actionColorIndex)]
            plantDetailsView.actionTextfield.tintColor = UIColor.colorsArray[Int(plant.actionColorIndex)]
            plantDetailsView.actionTextfield.textColor = UIColor.colorsArray[Int(plant.actionColorIndex)]
            notesTextView.text = plant.notes
            if let lastDate = plant.lastDateWatered {
                lastDateLabel.text = NSLocalizedString("Last: ", comment: "last time watered") + "\(DateFormatter.lastWateredDateFormatter.string(from: lastDate))"
            } else {
                lastDateLabel.text = NSLocalizedString("Brand New Plant", comment: "plant that hasn't been watered yet")
            }
        }
        
        // ADD Mode
        else {
            plantDetailsView.actionTextfield.text = NSLocalizedString("Water", comment: "water, default main action")
            // TODO: use passed in notepad here?
        }
    }
    
    /// Lays out all views needed
    private func setupSubViews() {
        
        view.backgroundColor = .customDetailBackgroundColor
        
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
        
        // Plant Details View
        contentView.addSubview(plantDetailsView)
        plantDetailsView.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor, constant: 8).isActive = true
        plantDetailsView.heightAnchor.constraint(equalToConstant: 76).isActive = true
        plantDetailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        plantDetailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                        
        // Notification View
        contentView.addSubview(notificationView)
        notificationView.topAnchor.constraint(equalTo: plantDetailsView.bottomAnchor, constant: 12).isActive = true
        notificationView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        notificationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notificationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        // Notes Textview
        contentView.addSubview(notesTextView)
        notesTextView.topAnchor.constraint(equalTo: notificationView.bottomAnchor, constant: 8).isActive = true
        notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        notesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
