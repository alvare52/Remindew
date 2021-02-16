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
    
    /// Holds all other views (rounded rect)
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .customComponentColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    /// Displays plant name in it's preferred color
    var plantNameLabel: UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.colorsArray[0]
        label.tintColor = UIColor.colorsArray[0]
        label.text = "Name"
        label.font = .boldSystemFont(ofSize: 25)
        label.isEnabled = false
        label.autocorrectionType = .no
        label.textAlignment = .center
        return label
    }()
    
    /// Displays the icon image for this action/plant
    var iconImageButton: UIButton = {
        let imageView = UIButton()//UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = UIColor.colorsArray[0]
        imageView.setImage(UIImage.iconArray[0], for: .normal)
        return imageView
    }()
    
    /// Button used to cycle between color
    let colorChangeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = UIColor.colorsArray[0]
        button.setImage(UIImage(systemName: "paintbrush.fill"), for: .normal)
        return button
    }()
    
    /// Padding for rounded view portion (8pts)
    let standardPadding: CGFloat = 8
    
    var localColorsCount = 0 {
        
        didSet {
            
            if localColorsCount == UIColor.colorsArray.count {
                localColorsCount = 0
            }
            
            plantNameLabel.textColor = UIColor.colorsArray[localColorsCount]
            plantNameLabel.tintColor = UIColor.colorsArray[localColorsCount]
            iconImageButton.tintColor = UIColor.colorsArray[localColorsCount]
            colorChangeButton.tintColor = UIColor.colorsArray[localColorsCount]
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
    
    /// Layouts all UI elements
    private func setupSubviews() {
        
        backgroundColor = .customCellColor
        
        // Container View
        addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: standardPadding/2).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standardPadding/2).isActive = true
        
        // Icon image view
        containerView.addSubview(iconImageButton)
        iconImageButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: standardPadding).isActive = true
        iconImageButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        iconImageButton.widthAnchor.constraint(equalTo: iconImageButton.heightAnchor).isActive = true
        iconImageButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        iconImageButton.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)

        // Color Change Button
        containerView.addSubview(colorChangeButton)
        colorChangeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        colorChangeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -standardPadding).isActive = true
        colorChangeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        colorChangeButton.widthAnchor.constraint(equalTo: colorChangeButton.heightAnchor).isActive = true
        colorChangeButton.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
        
        // Plant name label
        containerView.addSubview(plantNameLabel)
        plantNameLabel.leadingAnchor.constraint(equalTo: iconImageButton.trailingAnchor, constant: standardPadding).isActive = true
        plantNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        plantNameLabel.trailingAnchor.constraint(equalTo: colorChangeButton.leadingAnchor, constant: -standardPadding).isActive = true
        plantNameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: CGFloat(0.5)).isActive = true
    }
    
    @objc private func changeColor() {
        
        localColorsCount += 1

        // update colors for passed in UIDatePicker and UISwitch
        applyColorsToDatePickerAndSwitch()
    }
    
    @objc private func changeIcon() {
        localIconCount += 1
    }
    
    // Passed in if inside of ReminderViewController to change these
    weak var datePicker: UIDatePicker?
    weak var notificationSwitch: UISwitch?
    
    // Changes colors of passed in ui elements (for ReminderViewController only)
    func applyColorsToDatePickerAndSwitch() {
        guard let datePicker = datePicker, let notificationSwitch = notificationSwitch else { return }
        datePicker.tintColor = UIColor.colorsArray[localColorsCount]
        notificationSwitch.onTintColor = UIColor.colorsArray[localColorsCount]
    }
}
