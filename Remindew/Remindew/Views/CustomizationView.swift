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
        label.backgroundColor = .yellow
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
        return imageView
    }()
    
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
        backgroundColor = .purple
        
        // Plant name label
        addSubview(plantNameLabel)
        plantNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        plantNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(0.5)).isActive = true
        plantNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: CGFloat(0.5)).isActive = true
        plantNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(10)).isActive = true
        
        // Icon image view
        addSubview(iconImageView)
        iconImageView.topAnchor.constraint(equalTo: plantNameLabel.topAnchor).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: plantNameLabel.trailingAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: plantNameLabel.bottomAnchor).isActive = true
//        iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: CGFloat(10)).isActive = true
        
    }
}
