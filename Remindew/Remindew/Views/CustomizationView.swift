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
    }
}
