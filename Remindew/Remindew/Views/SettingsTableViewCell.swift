//
//  SettingsTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/19/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

struct CustomSetting {
    var settingKey: String
}

class SettingsTableViewCell: UITableViewCell {
    
    /// Switch used to toggle setting on/off
    var optionSwitch: UISwitch!
    
    /// Displays setting's name
    var settingLabel: UILabel!
    
    /// 20 pt padding
    var standardMargin: CGFloat = CGFloat(20.0)
    
    /// Holds the key for this cell's setting
    var customSetting: String?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    /// Sets the cell's setting to the current value of its optionSwitch
    @objc func optionChanged(_ sender: UISwitch) {
        
        // make sure it actually has a setting set (link cell doesn't)
        guard let setting = customSetting else { return }
        switch setting {
        
        case .resultFillsSpeciesTextfield:
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .resultFillsSpeciesTextfield)
            
        case .darkThemeOn:
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .darkThemeOn)
            UIColor().updateToDarkOrLightTheme()
            
        case .usePlantImages:
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .usePlantImages)
            // Let main table view know to update table view
            NotificationCenter.default.post(name: .checkWateringStatus, object: self)
            
        case .usePlantColorOnLabel:
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .usePlantColorOnLabel)
            // Let main table view know to update table view
            NotificationCenter.default.post(name: .checkWateringStatus, object: self)
                        
        case .hideSilencedIcon:
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .hideSilencedIcon)
            // Let main table view know to update table view
            NotificationCenter.default.post(name: .checkWateringStatus, object: self)
            
        case .sortPlantsBySpecies:
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .sortPlantsBySpecies)
            // Let main table view know we changed the labels setting
            NotificationCenter.default.post(name: .updateSortDescriptors, object: self)
            
        case .useBiggerImages:
            // Let PlantTableViewCells know to setup their subviews again
            UserDefaults.standard.set(optionSwitch.isOn, forKey: .useBiggerImages)
            NotificationCenter.default.post(name: .updateImageSizes, object: self)
            
        default:
            break
        }
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
    
        contentView.backgroundColor = UIColor.customCellColor
        
        // Setting Label
        let label = UILabel()
        contentView.addSubview(label)
        self.settingLabel = label
        settingLabel.translatesAutoresizingMaskIntoConstraints = false
        settingLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        settingLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                            constant: 20).isActive = true
        settingLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(0.7)).isActive = true
        settingLabel.font = .systemFont(ofSize: 16)
        
        // Switch
        let option = UISwitch()
        contentView.addSubview(option)
        self.optionSwitch = option
        optionSwitch.translatesAutoresizingMaskIntoConstraints = false
        optionSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardMargin).isActive = true
        optionSwitch.centerYAnchor.constraint(equalTo: settingLabel.centerYAnchor).isActive = true
        optionSwitch.addTarget(self, action: #selector(optionChanged), for: .valueChanged)
        // hide here because hiding in cellForRow doesn't work right
        optionSwitch.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
