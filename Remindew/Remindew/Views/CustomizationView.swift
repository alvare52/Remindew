//
//  CustomizationView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/28/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

class CustomizationView: UIView {
    
    // MARK: - Properties
    
    /// Displays plant name in it's preferred color
    var plantNameLabel: UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.colorsArray[0]
        label.text = "Name"
        label.font = .boldSystemFont(ofSize: 25)
        label.isEnabled = false
        label.autocorrectionType = .no
        return label
    }()
    
    /// Displays the icon image for this action/plant
    var iconImageButton: UIButton = {
        let imageView = UIButton()//UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .customCellColor
        imageView.tintColor = UIColor.colorsArray[0]
        imageView.setImage(UIImage.iconArray[0], for: .normal)
        return imageView
    }()
    
    /// Button used to cycle between color
    let colorChangeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.colorsArray[0]
        return button
    }()
    
    var localColorsCount = 0 {
        didSet {
            if localColorsCount == UIColor.colorsArray.count {
                localColorsCount = 0
            }
            plantNameLabel.textColor = UIColor.colorsArray[localColorsCount]
            iconImageButton.tintColor = UIColor.colorsArray[localColorsCount]
            colorChangeButton.backgroundColor = UIColor.colorsArray[localColorsCount]
        }
    }
    
    var localIconCount = 0 {
        didSet {
            if localIconCount == UIImage.iconArray.count {
                localIconCount = 0
            }
            iconImageButton.setImage(UIImage.iconArray[localIconCount], for: .normal)
        }
    }
    
    // MARK: - View Life Cycle
    
    // uses this one
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init with frame")
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init with coder")
        setupSubviews()
    }
    
    var buttonCornerRadius: CGFloat {
        print("\((frame.width * 0.1) / 2)")
        return (frame.width * 0.1) / 2
    }
    
    /// Layouts all UI elements
    private func setupSubviews() {
        
        backgroundColor = .customCellColor
        
        // Plant name label
        addSubview(plantNameLabel)
        plantNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        plantNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(0.7)).isActive = true
        plantNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: CGFloat(0.5)).isActive = true
        plantNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        // Color Change Button
        addSubview(colorChangeButton)
//        colorChangeButton.topAnchor.constraint(equalTo: plantNameLabel.topAnchor).isActive = true
        colorChangeButton.centerYAnchor.constraint(equalTo: plantNameLabel.centerYAnchor).isActive = true
        colorChangeButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        colorChangeButton.heightAnchor.constraint(equalTo: plantNameLabel.heightAnchor).isActive = true
        colorChangeButton.widthAnchor.constraint(equalTo: colorChangeButton.heightAnchor).isActive = true
        colorChangeButton.layer.cornerRadius = 15//buttonCornerRadius
        colorChangeButton.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
        
        // Icon image view
        addSubview(iconImageButton)
//        iconImageView.topAnchor.constraint(equalTo: plantNameLabel.topAnchor).isActive = true
        iconImageButton.trailingAnchor.constraint(equalTo: colorChangeButton.leadingAnchor, constant: -20).isActive = true
        iconImageButton.heightAnchor.constraint(equalTo: plantNameLabel.heightAnchor).isActive = true
        iconImageButton.widthAnchor.constraint(equalTo: iconImageButton.heightAnchor).isActive = true
        iconImageButton.centerYAnchor.constraint(equalTo: plantNameLabel.centerYAnchor).isActive = true
//        iconImageView.bottomAnchor.constraint(equalTo: plantNameLabel.bottomAnchor).isActive = true
//        iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(10)).isActive = true
        iconImageButton.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
        
    }
    
    @objc private func changeColor() {
        
        localColorsCount += 1
        colorChangeButton.backgroundColor = UIColor.colorsArray[localColorsCount]
        plantNameLabel.textColor = UIColor.colorsArray[localColorsCount]
        iconImageButton.tintColor = UIColor.colorsArray[localColorsCount]
        // update colors for passed in UIDatePicker and UISwitch
        applyColorsToDatePickerAndSwitch()
    }
    
    @objc private func changeIcon() {
        localIconCount += 1
        iconImageButton.setImage(UIImage.iconArray[localIconCount], for: .normal)
    }
    
    // NEW
    weak var datePicker: UIDatePicker?
    weak var notificationSwitch: UISwitch?
    
    // Changes colors of passed in ui elements (for ReminderViewController only)
    func applyColorsToDatePickerAndSwitch() {
        guard let datePicker = datePicker, let notificationSwitch = notificationSwitch else { return }
        datePicker.tintColor = UIColor.colorsArray[localColorsCount]
        notificationSwitch.onTintColor = UIColor.colorsArray[localColorsCount]
    }
}
