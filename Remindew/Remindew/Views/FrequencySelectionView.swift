//
//  FrequencySelectionView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/17/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit
import Foundation

class FrequencySelectionView: UIView {
    
    // MARK: - Properties
    
    /// Label following textField that says "Every"
    let everyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Every", comment: "days label after frequency number")
        label.backgroundColor = .clear
        label.textColor = .mixedBlueGreen
        return label
    }()
    
    /// Textfield that is auto selected when tapping in view
    var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.text = "7"
        textField.backgroundColor = .clear
//        textField.textAlignment = .center
        textField.textColor = .mixedBlueGreen
        return textField
    }()
        
    /// Label following textField that says "Days"
    let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("days", comment: "days label after frequency number")
        label.backgroundColor = .clear
        label.textColor = .mixedBlueGreen
        return label
    }()
    
    /// Main color to use for all views (.mixedBlueGreen by default)
    var mainColor: UIColor = .mixedBlueGreen {
        didSet {
            updateColors()
        }
    }
    
    // MARK: - View Life Cycle

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
    
    /// Updates all UI to use mainColor passed in from ReminderViewController's actionCustomizationView
    private func updateColors() {
        everyLabel.textColor = mainColor
        textField.textColor = mainColor
        daysLabel.textColor = mainColor
    }
    
    /// Tap into textField whenever view is touched since textField might be too small
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
    }
        
    /// Lays out textField and day button
    private func setupSubviews() {
        
        // View
        backgroundColor = UIColor.customComponentColor
        layer.cornerRadius = 6
        
        // Every Label
        addSubview(everyLabel)
        everyLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        everyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        everyLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4).isActive = true
        everyLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Text Field
        addSubview(textField)
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: everyLabel.trailingAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Days Label
        addSubview(daysLabel)
        daysLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        daysLabel.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 2).isActive = true
        daysLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        daysLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

}
