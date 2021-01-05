//
//  ReminderTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 1/4/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
        return view
    }()
    
    /// Displays Reminder's name
    let reminderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .orange
        return label
    }()
    
    /// Displays Reminder's progress (how soon it will go off)
    let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.tintColor = .mintGreen
        return progress
    }()
    
    /// Label that displays alarmDate
    let alarmDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .green
        return label
    }()
    
    /// Label that displays how many days are left until reminder goes off
    let timeLeftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        return label
    }()
    
    /// Button to complete reminder action to set new reminder
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 8 pt padding
    var standardMargin: CGFloat = CGFloat(8.0)
    
    var reminder: Reminder? {
        didSet {
            updateViews()
        }
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    private func updateViews() {
        guard let reminder = reminder else { return }
        reminderLabel.text = reminder.actionName
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
        
        // Container View
        addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Complete Button
        containerView.addSubview(completeButton)
        completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        completeButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        completeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.15).isActive = true
        
        // Name Label
        containerView.addSubview(reminderLabel)
        reminderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        reminderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        reminderLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5).isActive = true
        
        // Progress View
        containerView.addSubview(progressView)
        progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor).isActive = true
        progressView.widthAnchor.constraint(equalTo: reminderLabel.widthAnchor).isActive = true
        
        // Alarm Date Label
        containerView.addSubview(alarmDateLabel)
        alarmDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4).isActive = true
        alarmDateLabel.leadingAnchor.constraint(equalTo: reminderLabel.trailingAnchor).isActive = true
        alarmDateLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.35).isActive = true
        
        // Time Left Label
        containerView.addSubview(timeLeftLabel)
        timeLeftLabel.topAnchor.constraint(equalTo: alarmDateLabel.bottomAnchor).isActive = true
        timeLeftLabel.leadingAnchor.constraint(equalTo: progressView.trailingAnchor).isActive = true
        timeLeftLabel.widthAnchor.constraint(equalTo: alarmDateLabel.widthAnchor).isActive = true
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


//class ReminderTableViewCell: UITableViewCell {
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
