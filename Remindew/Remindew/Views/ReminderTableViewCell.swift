//
//  ReminderTableViewCell.swift
//  Remindew
//
//  Created by Jorge Alvarez on 1/4/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    /// Contains all subviews
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .yellow
        return view
    }()
    
    /// Displays Reminder's name
    let reminderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .orange
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .systemPurple
        return label
    }()
    
    /// Displays Reminder's progress (how soon it will go off)
    let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.tintColor = .mintGreen
        progress.progress = 0.5
        return progress
    }()
    
    /// Label that displays alarmDate
    let alarmDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .green
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .lightGray
        return label
    }()
    
    /// Label that displays how many days are left until reminder goes off
    let timeLeftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .blue
        label.text = "18 days left"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    /// Button to complete reminder action to set new reminder
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = .brown
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ant.fill"), for: .normal)
        button.tintColor = .systemPurple
        return button
    }()
    
    /// 8 pt padding
    var standardMargin: CGFloat = CGFloat(8.0)
    
    /// Holds Reminder that is displayed
    var reminder: Reminder? {
        didSet {
            updateViews()
        }
    }
    
    /// Jan 10, 2021
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM d, yyyy"
        formatter.dateStyle = .medium
        return formatter
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    private func updateViews() {
        // START
//        let startDate = Date()
        
        guard let reminder = reminder else { return }
        reminderLabel.text = reminder.actionName
        alarmDateLabel.text = dateFormatter.string(from: reminder.alarmDate ?? Date())
        progressView.progressTintColor = UIColor.colorsArray[Int(reminder.colorIndex)]
        
//        let daysLeftInt16 = Int(reminder.alarmDate!.timeIntervalSinceNow / 86400.0)
        timeLeftLabel.text = "\(Int(reminder.alarmDate!.timeIntervalSinceNow / 86400.0))" + " days left"
        
     
        // Randomly slows down simulator and clicking on plant doesn't do anything (pinch zoom bug?)
//        let modded = daysLeftInt16 % reminder.frequency
//        let progressFloat = 1.0 - (Float(modded) / Float(reminder.frequency))
//        progressView.progress = progressFloat
//        reminderLabel.text = "\(progressFloat)"
        
        // END
//        let finishDate = Date()
//        print("Execution time: \(finishDate.timeIntervalSince(startDate))")
    }
    
    ///
    @objc private func completeButtonTapped() {
        print("complete tapped")
    }
    
    /// Sets up all custom views
    private func setUpSubviews() {
        
        
        // Container View
        addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Complete Button
        containerView.addSubview(completeButton)
        completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        completeButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        completeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.15).isActive = true
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        completeButton.isHidden = true
        
        // Name Label
        containerView.addSubview(reminderLabel)
        reminderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        reminderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        reminderLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45).isActive = true
//        reminderLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8).isActive = true
        
        // Progress View
        containerView.addSubview(progressView)
        progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 4).isActive = true
        progressView.widthAnchor.constraint(equalTo: reminderLabel.widthAnchor).isActive = true
        
        // Alarm Date Label
        containerView.addSubview(alarmDateLabel)
        alarmDateLabel.topAnchor.constraint(equalTo: reminderLabel.topAnchor).isActive = true
        alarmDateLabel.bottomAnchor.constraint(equalTo: reminderLabel.bottomAnchor).isActive = true
        alarmDateLabel.leadingAnchor.constraint(equalTo: reminderLabel.trailingAnchor, constant: 16).isActive = true
//        alarmDateLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.35).isActive = true
        alarmDateLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor).isActive = true
//        alarmDateLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        // Time Left Label
        containerView.addSubview(timeLeftLabel)
//        timeLeftLabel.topAnchor.constraint(equalTo: alarmDateLabel.bottomAnchor).isActive = true
//        timeLeftLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        timeLeftLabel.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4).isActive = true
        timeLeftLabel.leadingAnchor.constraint(equalTo: alarmDateLabel.leadingAnchor).isActive = true
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
