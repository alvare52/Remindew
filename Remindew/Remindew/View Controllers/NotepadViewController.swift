//
//  NotepadViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/26/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class NotepadViewController: UIViewController {

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
        label.text = "Last: Friday 12/25/20, 10:00 a. m."
        label.textColor = .waterBlue
        label.textAlignment = .left
        label.numberOfLines = 1
        label.contentMode = .bottom
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
    
    let reminderTitleTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Reminder Title"
        textfield.backgroundColor = .white
        textfield.contentVerticalAlignment = .bottom
        return textfield
    }()
    
    let reminderMessageTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Reminder Message"
        textfield.backgroundColor = .white
        textfield.contentVerticalAlignment = .bottom
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
        textfield.contentVerticalAlignment = .bottom
        return textfield
    }()
    
    /// Textview for any notes
    let notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Notes"
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .white
        textView.contentMode = .left
        return textView
    }()
    
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
            // update the rest of the views here later
        }
        
        // ADD Mode
        else {
            
        }
    }
    
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        print("Save button tapped")
        dismiss(animated: true, completion: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
        updateViews()
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
        scientificLine.topAnchor.constraint(equalTo: scientificNameTextfield.bottomAnchor).isActive = true
        scientificLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scientificLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scientificLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        scientificLine.backgroundColor = .lightGray
        
        // Reminder Title ("Time to water your plant") Textfield
        contentView.addSubview(reminderTitleTextfield)
        reminderTitleTextfield.topAnchor.constraint(equalTo: scientificLine.bottomAnchor).isActive = true
        reminderTitleTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        reminderTitleTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        reminderTitleTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Title Line
        contentView.addSubview(titleLine)
        titleLine.topAnchor.constraint(equalTo: reminderTitleTextfield.bottomAnchor).isActive = true
        titleLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        titleLine.backgroundColor = .lightGray

        // Reminder Message Textfield
        contentView.addSubview(reminderMessageTextfield)
        reminderMessageTextfield.topAnchor.constraint(equalTo: titleLine.bottomAnchor).isActive = true
        reminderMessageTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        reminderMessageTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        reminderMessageTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Message Line
        contentView.addSubview(messageLine)
        messageLine.topAnchor.constraint(equalTo: reminderMessageTextfield.bottomAnchor).isActive = true
        messageLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        messageLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        messageLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        messageLine.backgroundColor = .lightGray
        
        // Location Textfield
        contentView.addSubview(locationTextfield)
        locationTextfield.topAnchor.constraint(equalTo: messageLine.bottomAnchor).isActive = true
        locationTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        locationTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4).isActive = true
        locationTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Location Line
        contentView.addSubview(locationLine)
        locationLine.topAnchor.constraint(equalTo: locationTextfield.bottomAnchor).isActive = true
        locationLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        locationLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        locationLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        locationLine.backgroundColor = .lightGray
        
        // Action Name ("Water")
        contentView.addSubview(actionTextfield)
        actionTextfield.topAnchor.constraint(equalTo: messageLine.bottomAnchor).isActive = true
        actionTextfield.leadingAnchor.constraint(equalTo: locationTextfield.trailingAnchor).isActive = true
        actionTextfield.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        actionTextfield.heightAnchor.constraint(equalTo: saveButton.heightAnchor).isActive = true
        
        // Notes Textview
        contentView.addSubview(notesTextView)
        notesTextView.topAnchor.constraint(equalTo: locationLine.bottomAnchor).isActive = true
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