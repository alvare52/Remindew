//
//  NotificationView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 1/4/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

/// UIView that looks like a Nofification banner. Contains 2 textfields to take in custom Title and Message
class NotificationView: UIView {
    
    // MARK: - Properties
    
    /// Notification bubble view (80 pts height), holds title and message textfields
    let notificationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .customComponentColor//.secondarySystemBackground
        return view
    }()
    
    /// Displays small app icon image in top left corner of notification view
    let smallIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = .white
        imageView.image = UIImage.smallAppIconImage
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// Displays name of app in notification view (REMINDEW)
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .lightGray
        label.textAlignment = .left
        label.text = "REMINDEW"
        return label
    }()
    
    /// Displays how many minutes ago notification was sent (purely visual)
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.text = "16m ago"
        label.textAlignment = .right
        return label
    }()
    
    let reminderTitleTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.text = .defaultTitleString()
        textfield.backgroundColor = .clear
        textfield.font = .systemFont(ofSize: 14, weight: .semibold)
        textfield.contentVerticalAlignment = .bottom
        return textfield
    }()
    
    let reminderMessageTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.text = ""
        textfield.font = .systemFont(ofSize: 14)
        textfield.backgroundColor = .clear
        textfield.contentVerticalAlignment = .top
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
        notificationView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        notificationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        notificationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        // Small Icon ImageView
        notificationView.addSubview(smallIconImageView)
        smallIconImageView.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10).isActive = true
        smallIconImageView.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor, constant: 12).isActive = true
        smallIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        smallIconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        // App Name Label
        notificationView.addSubview(appNameLabel)
        appNameLabel.centerYAnchor.constraint(equalTo: smallIconImageView.centerYAnchor).isActive = true
        appNameLabel.leadingAnchor.constraint(equalTo: smallIconImageView.trailingAnchor, constant: 8).isActive = true
        appNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Time Label
        notificationView.addSubview(timeLabel)
        timeLabel.centerYAnchor.constraint(equalTo: smallIconImageView.centerYAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor, constant: -16).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
        
        // Reminder Title ("Time to water your plant") Textfield
        notificationView.addSubview(reminderTitleTextfield)
        reminderTitleTextfield.topAnchor.constraint(equalTo: smallIconImageView.bottomAnchor, constant: 4).isActive = true
        reminderTitleTextfield.leadingAnchor.constraint(equalTo: smallIconImageView.leadingAnchor).isActive = true
        reminderTitleTextfield.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor,
                                                         constant: -16).isActive = true
        
        // Reminder Message Textfield
        notificationView.addSubview(reminderMessageTextfield)
        reminderMessageTextfield.topAnchor.constraint(equalTo: reminderTitleTextfield.bottomAnchor).isActive = true
        reminderMessageTextfield.leadingAnchor.constraint(equalTo: reminderTitleTextfield.leadingAnchor).isActive = true
        reminderMessageTextfield.trailingAnchor.constraint(equalTo: reminderTitleTextfield.trailingAnchor).isActive = true
    }
    
}
