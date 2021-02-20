//
//  PlantsTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/8/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class PlantsTableViewCell: UITableViewCell {
    
    /// Container view that holds all other view elements
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .customCellColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    /// Displays image from plant's image url (or default image if there is none)
    var plantIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    /// Image View that's used if user want plant image to show instead of icons
    var userPlantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.defaultImage
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    /// Button that shows which reminder needs attention
    var reminderButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    /// Button that shows if a plant is silenced or not
    var silencedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.setImage(UIImage(systemName: "moon.fill"), for: .normal)
        button.tintColor = .systemGray3
        return button
    }()
    
    /// Displays plant's nickname
    var nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 1
        return label
    }()
        
    /// Displays plant's scienfific name (if any) in italics
    var speciesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .customTimeLabelColor
        label.font = .systemFont(ofSize: 17.0)
        label.numberOfLines = 1
        return label
    }()
    
    /// Displays days that reminder will go off
    var daysLabel: UILabel = {
        print("making daysLabel")
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .italicSystemFont(ofSize: 17)
        label.textColor = .systemGray2
        label.numberOfLines = 1
        return label
    }()
    
    /// Displays time that reminder will go off each day
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .customTimeLabelColor
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    /// 16 pt padding
    var standardMargin: CGFloat = CGFloat(16.0)
    
    /// Plant that's passed in from PlantsTableViewController
    var plant: Plant? {
        didSet {
            updateView()
        }
    }
        
    /// Sets the cells views when it is passed in a plant
    private func updateView() {
        
        guard let plant = plant else { return }
        guard let nickname = plant.nickname, let species = plant.species else { return }
                
        // Nickname, Species, Days, and Time Labels
        updateLabels(plant: plant, nickname: nickname, species: species)
        
        // Plant Icon or Image
        updatePlantImageOrIcon(plant: plant)
        
        // Silenced and Reminder Buttons
        updateStatusButtons(plant: plant)
    }
    
    /// Sets Nickname, Species, Days, and Time labels based on settings
    private func updateLabels(plant: Plant, nickname: String, species: String) {
        
        // Main Label Color
        if UserDefaults.standard.bool(forKey: .usePlantColorOnLabel) {
            nicknameLabel.textColor = UIColor.colorsArray[Int(plant.plantColorIndex)]
        } else {
            nicknameLabel.textColor = .mixedBlueGreen
        }
                        
        // Nickname / Species Labels
        if UserDefaults.standard.bool(forKey: .sortPlantsBySpecies) {
            nicknameLabel.text = species
            speciesLabel.text = nickname
        } else {
            nicknameLabel.text = nickname
            speciesLabel.text = species
        }
        
        timeLabel.text = "\(DateFormatter.timeOnlyDateFormatter.string(from: plant.water_schedule!))"
        daysLabel.text = "\(returnDaysString(plant: plant))"
    }
    
    /// Sets main plant icon/image based on settings
    private func updatePlantImageOrIcon(plant: Plant) {
        
        // Plant Icon or Image
        if UserDefaults.standard.bool(forKey: .usePlantImages) {
            // Image
            userPlantImageView.isHidden = false
            plantIconButton.isHidden = true
            userPlantImageView.image = UIImage.loadImageFromDiskWith(fileName: "userPlant\(plant.identifier!)")
        } else {
            // Icon
            plantIconButton.isHidden = false
            plantIconButton.setImage(UIImage.iconArray[Int(plant.plantIconIndex)], for: .normal)
            plantIconButton.tintColor = UIColor.colorsArray[Int(plant.plantColorIndex)]
            userPlantImageView.isHidden = true
        }
    }
    
    /// Sets reminderButton icon to Water, Reminder, Silenced, or None
    private func updateStatusButtons(plant: Plant) {
        
        // Silenced Button
        silencedButton.isHidden = plant.isEnabled ? true : false
        
        // Reminder Button
        reminderButton.isHidden = false
        
        // Watering
        if plant.needsWatering {
            reminderButton.setImage(UIImage.iconArray[Int(plant.actionIconIndex)], for: .normal)
            reminderButton.tintColor = UIColor.colorsArray[Int(plant.actionColorIndex)]
            return
        }
        
        // Reminder
        if let reminder = plant.checkPlantsReminders() {
            reminderButton.setImage(UIImage.iconArray[Int(reminder.iconIndex)], for: .normal)
            reminderButton.tintColor = UIColor.colorsArray[Int(reminder.colorIndex)]
            return
        }
        
        // None (does not need water or reminder)
        reminderButton.isHidden = true
    }
    
    /// Returns a String of all days selected separated by a space
    func returnDaysString(plant: Plant) -> String {
        
        let resultMap = plant.frequency!.map { "\(String.dayInitials[Int($0 - 1)])" }
            
        if resultMap.count == 7 {
            return NSLocalizedString("Every day", comment: "Every day as in all 7 days are selected")
        }
        
        return resultMap.joined(separator: " ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
        
        contentView.backgroundColor = .customBackgroundColor
        
        // Container View
        addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(8.0)).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(20.0)).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(-20.0)).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-8.0)).isActive = true
        
        // Time Label
        containerView.addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standardMargin).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.37).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: CGFloat(-8.0)).isActive = true
        
        // Nickname Label
        containerView.addSubview(nicknameLabel)
        nicknameLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
        nicknameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: standardMargin).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        nicknameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3).isActive = true
        
        // Plant Icon
        containerView.addSubview(plantIconButton)
        plantIconButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        plantIconButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        plantIconButton.widthAnchor.constraint(equalTo: plantIconButton.heightAnchor).isActive = true
        plantIconButton.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor).isActive = true
        
        // Reminder Button
        containerView.addSubview(reminderButton)
        reminderButton.leadingAnchor.constraint(equalTo: plantIconButton.trailingAnchor, constant: 8).isActive = true
        reminderButton.centerYAnchor.constraint(equalTo: plantIconButton.centerYAnchor).isActive = true
        reminderButton.widthAnchor.constraint(equalTo: plantIconButton.widthAnchor, multiplier: 0.33).isActive = true
        reminderButton.heightAnchor.constraint(equalTo: reminderButton.widthAnchor).isActive = true
        
        // Silenced Button
        containerView.addSubview(silencedButton)
        silencedButton.trailingAnchor.constraint(equalTo: plantIconButton.leadingAnchor, constant: -8).isActive = true
        silencedButton.centerYAnchor.constraint(equalTo: plantIconButton.centerYAnchor).isActive = true
        silencedButton.widthAnchor.constraint(equalTo: plantIconButton.widthAnchor, multiplier: 0.33).isActive = true
        silencedButton.heightAnchor.constraint(equalTo: silencedButton.widthAnchor).isActive = true
        
        // Species Label
        containerView.addSubview(speciesLabel)
        speciesLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor).isActive = true
        speciesLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        speciesLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        speciesLabel.heightAnchor.constraint(equalTo: plantIconButton.heightAnchor, multiplier: 0.5).isActive = true
        
        // User Plant Image View (round plant image)
        containerView.addSubview(userPlantImageView)
        userPlantImageView.heightAnchor.constraint(equalTo: plantIconButton.heightAnchor, multiplier: 0.9).isActive = true
        userPlantImageView.widthAnchor.constraint(equalTo: userPlantImageView.heightAnchor).isActive = true
        userPlantImageView.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor).isActive = true
        userPlantImageView.centerYAnchor.constraint(equalTo: speciesLabel.bottomAnchor).isActive = true
        
        // Days Label
        containerView.addSubview(daysLabel)
        daysLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor).isActive = true
        daysLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        daysLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        daysLabel.heightAnchor.constraint(equalTo: plantIconButton.heightAnchor, multiplier: 0.5).isActive = true
        
    }
}
