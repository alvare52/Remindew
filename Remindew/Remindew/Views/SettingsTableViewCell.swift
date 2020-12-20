//
//  SettingsTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/19/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    /// Switch used to toggle setting on/off
    var optionSwitch: UISwitch!
    
    /// Displays setting's name
    var settingLabel: UILabel!
    
    /// Switch won't hide or change alpha
    var blockingView: UIView!
    
    /// 8 pt padding
    var standardMargin: CGFloat = CGFloat(20.0)
            
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
    
        contentView.backgroundColor = UIColor.customCellColor
        
        // Setting Label
        let label = UILabel()
        addSubview(label)
        self.settingLabel = label
        settingLabel.translatesAutoresizingMaskIntoConstraints = false
        settingLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        settingLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                            constant: standardMargin).isActive = true
        settingLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(0.7)).isActive = true
        
        // Switch
        let option = UISwitch()
        addSubview(option)
        self.optionSwitch = option
        optionSwitch.translatesAutoresizingMaskIntoConstraints = false
        optionSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        optionSwitch.centerYAnchor.constraint(equalTo: settingLabel.centerYAnchor).isActive = true
        optionSwitch.onTintColor = .lightLeafGreen
        
        // Blocking View
        let blocking = UIView()
        addSubview(blocking)
        self.blockingView = blocking
        blockingView.translatesAutoresizingMaskIntoConstraints = false
        blockingView.topAnchor.constraint(equalTo: optionSwitch.topAnchor).isActive = true
        blockingView.leadingAnchor.constraint(equalTo: optionSwitch.leadingAnchor).isActive = true
        blockingView.trailingAnchor.constraint(equalTo: optionSwitch.trailingAnchor, constant: CGFloat(2.0)).isActive = true
        blockingView.bottomAnchor.constraint(equalTo: optionSwitch.bottomAnchor).isActive = true
        blockingView.backgroundColor = UIColor.customCellColor
        blockingView.isHidden = true

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
