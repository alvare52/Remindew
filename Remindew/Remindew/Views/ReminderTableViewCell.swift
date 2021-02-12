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
        button.setImage(UIImage.iconArray[0], for: .normal)
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
    
    /// Holds PlantController that's passed in from DetailViewController to update reminders
    var plantController: PlantController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    private func updateViews() {
        
        guard let reminder = reminder else { return }
        reminderLabel.text = reminder.actionName
        reminderLabel.textColor = UIColor.colorsArray[Int(reminder.colorIndex)]
        alarmDateLabel.text = DateFormatter.dateOnlyDateFormatter.string(from: reminder.alarmDate ?? Date())
        progressView.progressTintColor = UIColor.colorsArray[Int(reminder.colorIndex)]
        
        completeButton.setImage(UIImage.iconArray[Int(reminder.iconIndex)], for: .normal)
        completeButton.tintColor = UIColor.colorsArray[Int(reminder.colorIndex)]
                
        reminderLabel.alpha = reminder.isEnabled ? 1.0 : 0.3
        progressView.alpha = reminder.isEnabled ? 1.0 : 0.3
        
        updateProgressView(reminder: reminder)
    }
    
    /// Takes in a Reminder and updates the progressView based on the Reminder's lastDate or dateCreated
    func updateProgressView(reminder: Reminder) {
        
        // assume that this is a new reminder
        var totalProgress = reminder.alarmDate!.timeIntervalSince(reminder.dateCreated!) / 86400.0
        let daysLeft = reminder.alarmDate!.timeIntervalSinceNow / 86400.0
        
        // TODO: needs localization
        timeLeftLabel.text = "\(Int(daysLeft))" + " days left"
        if Int(daysLeft) == 1 {
            timeLeftLabel.text = "\(Int(daysLeft))" + " day left"
        }
        
        // if it is NOT a new reminder, use the lastDate instead of dateCreated for total time
        if let lastDate = reminder.lastDate {
            totalProgress = reminder.alarmDate!.timeIntervalSince(lastDate) / 86400.0
        }
        
        // total time (start to finish) - days that are left / total time again
        progressView.progress = Float((totalProgress - daysLeft) / totalProgress)
        
        // goes off in 24 hours (either today or tomorrow)
        if daysLeft < 1 {
            
            let currentDayComps = Calendar.current.dateComponents([.day], from: Date())
            let currentDay = currentDayComps.day!
            
            let reminderDayComps = Calendar.current.dateComponents([.day], from: reminder.alarmDate!)
            let alarmDateDay = reminderDayComps.day!
            
            let todayString = NSLocalizedString("Today", comment: "today")
            let tomorrowString = NSLocalizedString("Tomorrow", comment: "tomorrow")
            
            alarmDateLabel.text = currentDay == alarmDateDay ? todayString : tomorrowString
            timeLeftLabel.text = "at \(DateFormatter.timeOnlyDateFormatter.string(from: reminder.alarmDate!))"
            
            // has already passed
            if daysLeft <= 0 {
                alarmDateLabel.text = "Tap button"
                timeLeftLabel.text = "to complete"
                progressView.progress = 1.0
                completeButton.isHidden = false
            } else {
                completeButton.isHidden = true
            }
        }
    }
    
    /// Sets new alarmDate for Reminder, sets new lastDate value, and hides completeButton
    @objc private func completeButtonTapped() {
        print("complete tapped")
        // set lastDate
        guard let reminder = reminder else { return }
        
        // update lastDate with time action was completed and set new alarmDate
        plantController?.updateReminderDates(reminder: reminder)
        // hide complete button
        completeButton.isHidden = true
        // update views
        updateViews()
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
