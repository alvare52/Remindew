//
//  PlantDetailsView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/21/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

class PlantDetailsView: UIView {
    
    // MARK: - Properties
    
    /// Notification bubble view (80 pts height), holds title and message textfields
    let notificationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .clear
        return view
    }()
    
    let actionTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.text = NSLocalizedString("Water", comment: "water")
        textfield.backgroundColor = .customComponentColor
        textfield.layer.cornerRadius = 15
        textfield.borderStyle = .none
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 14, weight: .semibold)
        textfield.contentVerticalAlignment = .center
        return textfield
    }()
    
    let locationTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.text = ""
        textfield.backgroundColor = .customComponentColor
        textfield.layer.cornerRadius = 15
        textfield.font = .systemFont(ofSize: 14, weight: .semibold)
        textfield.placeholder = NSLocalizedString("Location", comment: "where is the plant located")
        textfield.contentVerticalAlignment = .center
        textfield.tintColor = .mixedBlueGreen
        textfield.textAlignment = .center
        return textfield
    }()
    
    let scientificNameTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.backgroundColor = .customComponentColor
        textfield.contentVerticalAlignment = .top
        textfield.font = .italicSystemFont(ofSize: 17)
        textfield.placeholder = NSLocalizedString("Scientific Name", comment: "scientific name / species of plant")
        textfield.autocorrectionType = .no
        textfield.layer.cornerRadius = 15
        textfield.contentVerticalAlignment = .center
        textfield.tintColor = .mixedBlueGreen
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 31))
        textfield.leftViewMode = .always
        return textfield
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
    
    private func setupSubviews() {
                
        // Notification View
        addSubview(notificationView)
        notificationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        notificationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        notificationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        notificationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        // Action Textfield
        notificationView.addSubview(actionTextfield)
        actionTextfield.topAnchor.constraint(equalTo: notificationView.topAnchor).isActive = true
        actionTextfield.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor).isActive = true
        actionTextfield.trailingAnchor.constraint(equalTo: notificationView.centerXAnchor, constant: -2).isActive = true
        actionTextfield.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
        // Location Textfield
        notificationView.addSubview(locationTextfield)
        locationTextfield.topAnchor.constraint(equalTo: notificationView.topAnchor).isActive = true
        locationTextfield.leadingAnchor.constraint(equalTo: notificationView.centerXAnchor, constant: 2).isActive = true
        locationTextfield.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor).isActive = true
        locationTextfield.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        // Scientific Name Textfield
        notificationView.addSubview(scientificNameTextfield)
        scientificNameTextfield.topAnchor.constraint(equalTo: actionTextfield.bottomAnchor, constant: 4).isActive = true
        scientificNameTextfield.leadingAnchor.constraint(equalTo: actionTextfield.leadingAnchor).isActive = true
        scientificNameTextfield.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor).isActive = true
        scientificNameTextfield.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
}
