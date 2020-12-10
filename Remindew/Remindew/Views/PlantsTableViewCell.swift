//
//  PlantsTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/8/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class PlantsTableViewCell: UITableViewCell {

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
    var standardMargin: CGFloat = CGFloat(20.0)
    
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
        
        contentView.layer.cornerRadius = 10
//        contentView.backgroundColor = .lightGray
        
        // Time Label
        let time = UILabel()
        addSubview(time)
        self.timeLabel = time
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(16.0)).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        timeLabel.font = .boldSystemFont(ofSize: 25)
        timeLabel.textColor = .secondaryLabel
        timeLabel.textAlignment = .center
        timeLabel.numberOfLines = 1
        
        // Nickname Label
        let label = UILabel()
        addSubview(label)
        self.nicknameLabel = label
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
        nicknameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                            constant: standardMargin).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
//        nicknameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
        nicknameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
//        nicknameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        nicknameLabel.textColor = .mixedBlueGreen
        nicknameLabel.font = .boldSystemFont(ofSize: 25)
        nicknameLabel.numberOfLines = 1
        
    
        // Image View
        let imageView = UIImageView()
        addSubview(imageView)
        self.plantImageView = imageView
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        plantImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: CGFloat(0.0)).isActive = true
        plantImageView.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        plantImageView.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor).isActive = true
        plantImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-16.0)).isActive = true
        plantImageView.contentMode = .scaleAspectFit
        
        // Species Label
        let species = UILabel()
        addSubview(species)
        self.speciesLabel = species
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor).isActive = true
        speciesLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        speciesLabel.trailingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor).isActive = true
        speciesLabel.heightAnchor.constraint(equalTo: plantImageView.heightAnchor, multiplier: 0.5).isActive = true
        speciesLabel.font = .italicSystemFont(ofSize: 17)
        speciesLabel.textColor = .secondaryLabel
        speciesLabel.numberOfLines = 1
        
        // Days Label
        let days = UILabel()
        addSubview(days)
        self.daysLabel = days
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor).isActive = true
        daysLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        daysLabel.trailingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor).isActive = true
        daysLabel.heightAnchor.constraint(equalTo: plantImageView.heightAnchor, multiplier: 0.5).isActive = true
        daysLabel.font = .italicSystemFont(ofSize: 17)
        daysLabel.textColor = .systemGray2
        daysLabel.numberOfLines = 1
    }
}
