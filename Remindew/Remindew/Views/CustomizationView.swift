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
    var plantNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .orange
        label.backgroundColor = .lightGray
        label.text = "Leaf Erikson"
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    
    /// Displays the icon image for this action/plant
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .leafGreen
        imageView.image = UIImage(systemName: "leaf.fill")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Button used to cycle between color
    let colorChangeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        return button
    }()
    
    let localColorsArray: [UIColor] = [UIColor.systemRed, UIColor.systemBlue, UIColor.systemGreen]
    var localColorsCount = 0
    
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
        backgroundColor = .white
        
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
        addSubview(iconImageView)
//        iconImageView.topAnchor.constraint(equalTo: plantNameLabel.topAnchor).isActive = true
        iconImageView.trailingAnchor.constraint(equalTo: colorChangeButton.leadingAnchor, constant: -16).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: plantNameLabel.heightAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: plantNameLabel.centerYAnchor).isActive = true
//        iconImageView.bottomAnchor.constraint(equalTo: plantNameLabel.bottomAnchor).isActive = true
//        iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(10)).isActive = true
        
    }
    
    @objc private func changeColor() {
        if localColorsCount == UIColor.colorsArray.count { localColorsCount = 0 }
        colorChangeButton.backgroundColor = UIColor.colorsArray[localColorsCount]
        plantNameLabel.textColor = UIColor.colorsArray[localColorsCount]
        iconImageView.tintColor = UIColor.colorsArray[localColorsCount]
        localColorsCount += 1
    }
}
