//
//  PlantsTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/8/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class PlantsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    /// Container view that holds all other view elements
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .customCellColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    /// Displays time that reminder will go off each day
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .customTimeLabelColor
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
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
        imageView.backgroundColor = .black
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
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .italicSystemFont(ofSize: 17)
        label.textColor = .systemGray2
        label.numberOfLines = 1
        return label
    }()
    
    /// 16 pt padding
    var standardMargin: CGFloat = CGFloat(16.0)
    
    /// Plant that's passed in from PlantsTableViewController
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: Constraints
    
    var timeLabelTop: NSLayoutConstraint?
    var timeLabelWidth: NSLayoutConstraint?
    var timeLabelHeight: NSLayoutConstraint?
    var timeLabelTrail: NSLayoutConstraint?
    var timeLabelBottom: NSLayoutConstraint?

    var plantIconTop: NSLayoutConstraint?
    var plantIconBottom: NSLayoutConstraint?
    var plantIconWidth: NSLayoutConstraint?
    var plantIconCenterX: NSLayoutConstraint?

    var reminderLead: NSLayoutConstraint?
    var reminderCenterY: NSLayoutConstraint?
    var reminderWidth: NSLayoutConstraint?
    var reminderHeight: NSLayoutConstraint?
    var reminderTop: NSLayoutConstraint?
    
    var silencedTrail: NSLayoutConstraint?
    var silencedCenterY: NSLayoutConstraint?
    var silencedWidth: NSLayoutConstraint?
    var silencedHeight: NSLayoutConstraint?
    
    var plantImageHeight: NSLayoutConstraint?
    var plantImageWidth: NSLayoutConstraint?
    var plantImageCenterX: NSLayoutConstraint?
    var plantImageCenterY: NSLayoutConstraint?

    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSubviews),
                                               name: .updateImageSizes,
                                               object: nil)
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Called when receiving notification that bigger/smaller image setting toggled
    @objc func updateSubviews() {
        
        // Right View Elements
        if UserDefaults.standard.bool(forKey: .useBiggerImages) {
            setupSubviewsBigImage()
        } else {
            setupSubviewsSmallImage()
        }
    }
    
    /// Deactivates constraints for timeLabel, userPlantImageView, plantIconButton, reminderButton, and silencedButton
    func deactivateRightViewContraints() {
                        
        // exit out if this is called for the first time
        guard timeLabelWidth != nil else { return }
        
        NSLayoutConstraint.deactivate([timeLabelWidth!, timeLabelHeight!, timeLabelTrail!,
                                     plantIconTop!, plantIconBottom!, plantIconWidth!, plantIconCenterX!,
                                     reminderLead!, reminderWidth!, reminderHeight!,
                                     silencedTrail!, silencedCenterY!, silencedWidth!, silencedHeight!,
                                     plantImageHeight!, plantImageWidth!, plantImageCenterX!, plantImageCenterY!])
        
        // These are the only ones that might be nil since they're not shared
        timeLabelTop?.isActive = false
        timeLabelBottom?.isActive = false
        reminderTop?.isActive = false
        reminderCenterY?.isActive = false
    }
    
    /// Sets up cell to display a bigger image and smaller time label
    func setupSubviewsBigImage() {
        
        // Deactivate ALL relevant constraints first
        deactivateRightViewContraints()
        
        // Time Label
        timeLabelBottom = timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -standardMargin)
        timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 90)
        timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 22.15)
        timeLabelTrail = timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        timeLabel.font = .systemFont(ofSize: 17)
        timeLabel.textColor = .customTimeLabelColor
        
        // Plant Icon Button
        plantIconBottom = plantIconButton.bottomAnchor.constraint(equalTo: timeLabel.topAnchor)
        plantIconTop = plantIconButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standardMargin)
        plantIconWidth = plantIconButton.widthAnchor.constraint(equalTo: plantIconButton.heightAnchor)
        plantIconCenterX = plantIconButton.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor)
        
        // Plant Image View
        plantImageHeight = userPlantImageView.heightAnchor.constraint(equalTo: plantIconButton.heightAnchor, multiplier: 0.9)
        plantImageWidth = userPlantImageView.widthAnchor.constraint(equalTo: userPlantImageView.heightAnchor)
        plantImageCenterX = userPlantImageView.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor)
        plantImageCenterY = userPlantImageView.centerYAnchor.constraint(equalTo: plantIconButton.centerYAnchor)
        userPlantImageView.layer.cornerRadius = 24.6825
        
        // Reminder Button
        reminderLead = reminderButton.leadingAnchor.constraint(equalTo: plantIconButton.trailingAnchor, constant: -6)
        reminderTop = reminderButton.topAnchor.constraint(equalTo: plantIconButton.topAnchor, constant: 2)
        reminderWidth = reminderButton.widthAnchor.constraint(equalToConstant: 14.619)
        reminderHeight = reminderButton.heightAnchor.constraint(equalTo: reminderButton.widthAnchor)
        
        // Silenced Button
        silencedTrail = silencedButton.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor)
        silencedCenterY = silencedButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor)
        silencedWidth = silencedButton.widthAnchor.constraint(equalToConstant: 11.075)
        silencedHeight = silencedButton.heightAnchor.constraint(equalTo: silencedButton.widthAnchor)
            
        // Activate Constraints
        NSLayoutConstraint.activate([timeLabelBottom!, timeLabelWidth!, timeLabelHeight!, timeLabelTrail!,
                                     plantIconBottom!, plantIconTop!, plantIconWidth!, plantIconCenterX!,
                                     plantImageHeight!, plantImageWidth!, plantImageCenterX!, plantImageCenterY!,
                                     reminderLead!, reminderTop!, reminderWidth!, reminderHeight!,
                                     silencedTrail!, silencedCenterY!, silencedWidth!, silencedHeight!])
    }
    
    /// Sets up cell to display a bigger time label and smaller image
    func setupSubviewsSmallImage() {
        
        // Deactivate ALL relevant constraints first
        deactivateRightViewContraints()
    
        // Time Label
        timeLabelTop = timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standardMargin)
        timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 116)
        timeLabelHeight = timeLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3)
        timeLabelTrail = timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        timeLabel.font = .boldSystemFont(ofSize: 23)
        timeLabel.textColor = .customTimeLabelColor
        
        // Plant Icon
        plantIconTop = plantIconButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor)
        plantIconBottom = plantIconButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        plantIconWidth = plantIconButton.widthAnchor.constraint(equalTo: plantIconButton.heightAnchor)
        plantIconCenterX = plantIconButton.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor)
        
        // Reminder Button
        reminderLead = reminderButton.leadingAnchor.constraint(equalTo: plantIconButton.trailingAnchor, constant: 8)
        reminderCenterY = reminderButton.centerYAnchor.constraint(equalTo: plantIconButton.centerYAnchor)
        reminderWidth = reminderButton.widthAnchor.constraint(equalToConstant: 14.619)
        reminderHeight = reminderButton.heightAnchor.constraint(equalTo: reminderButton.widthAnchor)
        
        // Silenced Button
        silencedTrail = silencedButton.trailingAnchor.constraint(equalTo: plantIconButton.leadingAnchor, constant: -8)
        silencedCenterY = silencedButton.centerYAnchor.constraint(equalTo: plantIconButton.centerYAnchor)
        silencedWidth = silencedButton.widthAnchor.constraint(equalToConstant: 14.619)
        silencedHeight = silencedButton.heightAnchor.constraint(equalTo: silencedButton.widthAnchor)
                
        // User Plant Image View (round plant image)
        plantImageHeight = userPlantImageView.heightAnchor.constraint(equalTo: plantIconButton.heightAnchor, multiplier: 0.9)
        plantImageWidth = userPlantImageView.widthAnchor.constraint(equalTo: userPlantImageView.heightAnchor)
        plantImageCenterX = userPlantImageView.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor)
        plantImageCenterY = userPlantImageView.centerYAnchor.constraint(equalTo: plantIconButton.centerYAnchor)
        userPlantImageView.layer.cornerRadius = 20
        
        // Activate Constraints
        NSLayoutConstraint.activate([timeLabelTop!, timeLabelWidth!, timeLabelHeight!, timeLabelTrail!,
                                     plantIconTop!, plantIconBottom!, plantIconWidth!, plantIconCenterX!,
                                     reminderLead!, reminderCenterY!, reminderWidth!, reminderHeight!,
                                     silencedTrail!, silencedCenterY!, silencedWidth!, silencedHeight!,
                                     plantImageHeight!, plantImageWidth!, plantImageCenterX!, plantImageCenterY!])

    }
    
    /// Sets up all custom views (big time label version)
    private func setUpSubviews() {
                
        contentView.backgroundColor = .customBackgroundColor
        
        // Container View
        addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(8.0)).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(20.0)).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(-20.0)).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-8.0)).isActive = true
        
        // Nickname Label
        containerView.addSubview(nicknameLabel)
        nicknameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: standardMargin).isActive = true
        nicknameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: standardMargin).isActive = true
        nicknameLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        nicknameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3).isActive = true
        
        // Species Label
        containerView.addSubview(speciesLabel)
        speciesLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor).isActive = true
        speciesLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        speciesLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        speciesLabel.heightAnchor.constraint(equalToConstant: 22.15).isActive = true
        
        // Days Label
        containerView.addSubview(daysLabel)
        daysLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor).isActive = true
        daysLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        daysLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        daysLabel.heightAnchor.constraint(equalToConstant: 22.15).isActive = true
                
        // Add subviews with variable constraints only once
        containerView.addSubview(timeLabel)
        containerView.addSubview(plantIconButton)
        containerView.addSubview(reminderButton)
        containerView.addSubview(silencedButton)
        containerView.addSubview(userPlantImageView)
        
        // Right View elements
        updateSubviews()
    }
    
    /// Sets the cells views when it is passed in a plant
    private func updateViews() {
        
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
        if UserDefaults.standard.bool(forKey: .hideSilencedIcon) {
            silencedButton.isHidden = true
        } else {
            silencedButton.isHidden = plant.isEnabled ? true : false
        }
        
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
}
