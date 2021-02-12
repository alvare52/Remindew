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
    var containerView: UIView!
    
    /// Displays image from plant's image url (or default image if there is none)
    var plantImageView: UIImageView!
    
    /// Displays plant's nickname
    var nicknameLabel: UILabel!
    
    /// Displays plant's scienfific name (if any) in italics
    var speciesLabel: UILabel!
    
    /// Displays days that reminder will go off
    var daysLabel: UILabel!
    
    /// Displays time that reminder will go off each day
    var timeLabel: UILabel!
    
    /// 8 pt padding
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
        
        let temp = Date(timeIntervalSinceNow: 60)

        let daysString = returnDaysString(plant: plant)
        
        nicknameLabel.text = nickname
        timeLabel.text = "\(DateFormatter.timeOnlyDateFormatter.string(from: plant.water_schedule ?? temp))"
        speciesLabel.text = species
        daysLabel.text = "\(daysString)"
                
        // TODO: Setting to use plant color for this?
//        nicknameLabel.textColor = UIColor.colorsArray[Int(plant.plantColorIndex)]
        
        if plant.isEnabled {
            nicknameLabel.alpha = 1.0
        } else {
            nicknameLabel.alpha = 0.3
        }
        
        if plant.needsWatering {
            plantImageView?.image = UIImage(named: "planticonwater")
        } else {
            plantImageView?.image = UIImage(named: "planticonleaf")
        }
    }
    
    /// Returns a string of all days selected separated by a space (to dispaly in table view cell)
    func returnDaysString(plant: Plant) -> String {
        
        var result = [String]()
        
        for day in plant.frequency! {
            // [1,2,3,7]
            result.append("\(String.dayInitials[Int(day - 1)])")
        }
        
        // if everyday basically
        if result.count == 7 {
            return NSLocalizedString("Every day", comment: "Every day as in all 7 days are selected")//"Every day"
        }
        return result.joined(separator: " ")
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
        
        let content = UIView()
        addSubview(content)
        self.containerView = content
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(8.0)).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(20.0)).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(-20.0)).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-8.0)).isActive = true
        containerView.backgroundColor = .customCellColor
        containerView.layer.cornerRadius = 15
        
        // Time Label
        let time = UILabel()
        containerView.addSubview(time)
        self.timeLabel = time
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CGFloat(16.0)).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.37).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: CGFloat(-8.0)).isActive = true
        timeLabel.font = .boldSystemFont(ofSize: 25)
        timeLabel.textColor = .customTimeLabelColor
        timeLabel.textAlignment = .center
        timeLabel.numberOfLines = 1
        
        // Nickname Label
        let label = UILabel()
        containerView.addSubview(label)
        self.nicknameLabel = label
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
        nicknameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                            constant: standardMargin).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        nicknameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3).isActive = true
        nicknameLabel.textColor = .mixedBlueGreen
        nicknameLabel.font = .boldSystemFont(ofSize: 25)
        nicknameLabel.numberOfLines = 1
        
    
        // Image View
        let imageView = UIImageView()
        containerView.addSubview(imageView)
        self.plantImageView = imageView
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        plantImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: CGFloat(0.0)).isActive = true
        plantImageView.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        plantImageView.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor).isActive = true
        plantImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: CGFloat(-16.0)).isActive = true
        plantImageView.contentMode = .scaleAspectFit
        
        // Species Label
        let species = UILabel()
        containerView.addSubview(species)
        self.speciesLabel = species
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor).isActive = true
        speciesLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        speciesLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        speciesLabel.heightAnchor.constraint(equalTo: plantImageView.heightAnchor, multiplier: 0.5).isActive = true
        speciesLabel.font = .systemFont(ofSize: 17.0)
        speciesLabel.textColor = .customTimeLabelColor
        speciesLabel.numberOfLines = 1
        
        // Days Label
        let days = UILabel()
        containerView.addSubview(days)
        self.daysLabel = days
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor).isActive = true
        daysLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        daysLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6).isActive = true
        daysLabel.heightAnchor.constraint(equalTo: plantImageView.heightAnchor, multiplier: 0.5).isActive = true
        daysLabel.font = .italicSystemFont(ofSize: 17)
        daysLabel.textColor = .systemGray2
        daysLabel.numberOfLines = 1
    }
}
