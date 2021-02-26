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
        textView.text = "Notes"
        textView.font = .systemFont(ofSize: 14)
        textView.layer.cornerRadius = 15
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
    
    /// Standard padding for left and right sides (20pts)
    let standardMargin: CGFloat = 20.0
    
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
    
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        
        let locationString = plantDetailsView.locationTextfield.text?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var action = plantDetailsView.actionTextfield.text ?? .waterLocalizedString
        action = action == "" ? .waterLocalizedString : action
        
        let name = plant == nil ? .defaultPlantNameLocalizedString : plant!.nickname!
        
        let notepad = NotePad(notes: notesTextView.text,
                              mainTitle: notificationView.reminderTitleTextfield.text ?? .defaultTitleString(),
                              mainMessage: notificationView.reminderMessageTextfield.text ?? .defaultMessageString(name: name, action: action),
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
        
        // Plant Details View
        contentView.addSubview(plantDetailsView)
        plantDetailsView.topAnchor.constraint(equalTo: lastDateLabel.bottomAnchor, constant: 4).isActive = true
        plantDetailsView.heightAnchor.constraint(equalToConstant: 76).isActive = true
        plantDetailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        plantDetailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                        
        // Notification View
        contentView.addSubview(notificationView)
        notificationView.topAnchor.constraint(equalTo: plantDetailsView.bottomAnchor, constant: 4).isActive = true
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
}

/// Struct that holds all information given in NotepadViewController
struct NotePad {
    var notes: String = ""
    var mainTitle: String = ""
    var mainMessage: String = ""
    var mainAction: String = NSLocalizedString("Water", comment: "water, default main action")
    var location: String = ""
    var scientificName: String = ""
}

extension String {
    
    /// Localized String for Water/Agua. Main action default
    static let waterLocalizedString = NSLocalizedString("Water", comment: "water, default main action")
    
    /// Localized String for Plant/Planta
    static let plantLocalizedString = NSLocalizedString("Plant", comment: "plant")
    
    /// Localized String for plant "name" if no name is given yet. Ex: One of your plants/ Una de sus plantas
    static let defaultPlantNameLocalizedString = NSLocalizedString("One of your plants", comment: "default plant name when none is given")
    
    /// Default Title for Plant's main action notification. Ex: "One of your plants needs attention." Localized
    static func defaultTitleString() -> String {
        return NSLocalizedString("One of your plants needs attention.", comment: "Message for notification")
    }
    
    /// Default Message for Plant's main action notification. Ex: "\(Name) needs \(action)." Localized
    static func defaultMessageString(name: String, action: String) -> String {
        return "\(name.capitalized)" + NSLocalizedString(" needs ", comment: "") + "\(action.lowercased())."
    }
}
