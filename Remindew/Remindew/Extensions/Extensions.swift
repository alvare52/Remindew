//
//  Extensions.swift
//  Remindew
//
//  Created by Jorge Alvarez on 11/20/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

// MARK: - NSNotification

extension NSNotification.Name {
    
    /// Posts a notification that tells the main table view to check the watering status and update the table
    static let checkWateringStatus = NSNotification.Name("checkWateringStatus")
    
    /// Posts a notification that tells main table view to update its sort descriptors
    static let updateSortDescriptors = NSNotification.Name("updateSortDescriptors")
    
    /// Posts a notification that tells the 3 main view controllers to update their appearance
//    static let updateAllViewControllerAppearance = NSNotification.Name("updateAllViewControllerAppearance")
}

// MARK: - String

extension String {
    
    /// Get/Set value of last temporary token for API
    static let lastTempToken = "lastTempToken"
    
    /// Get/Set value of last Date temporary token was set
    static let lastDateTokenGrabbed = "lastDateTokenGrabbed"
    
    /// Get/Set value of plant sorting by species
    static let sortPlantsBySpecies = "sortPlantsBySpecies"
    
    /// Get/Set value of setting for filling in species textfield with result's common name
    static let resultFillsSpeciesTextfield = "resultFillsSpeciesTextfield"
    
    /// Get/Set value of setting for using dark mode in this app only
    static let darkThemeOn = "darkThemeOn"
    
    /// Get/Set value of setting for using plant images instead of icons
    static let usePlantImages = "usePlantImages"
    
    static let sunday = NSLocalizedString("Sun", comment: "Sunday abbreviated")
    static let monday = NSLocalizedString("Mon", comment: "Monday abbreviated")
    static let tuesday = NSLocalizedString("Tue", comment: "Tuesday abbreviated")
    static let wednesday = NSLocalizedString("Wed", comment: "Wednesday abbreviated")
    static let thursday = NSLocalizedString("Thu", comment: "Thursday abbreviated")
    static let friday = NSLocalizedString("Fri", comment: "Friday abbreviated")
    static let saturday = NSLocalizedString("Sat", comment: "Saturday abbreviated")
    
    /// Array of NSLocalizedStrings just for label purposes
    static let dayInitials = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
    
    /// Array of random plant nicknames for when a user doesn't want to create their own
    static let randomNicknames: [String] = ["Twiggy", "Leaf Erikson", "Alvina", "Thornhill", "Plant 43",
                                            "Lily", "Leshy", "Greenman", "Bud Dwyer", "Treebeard",
                                            "Cilan", "Milo", "Erika", "Gardenia", "Ramos"]
    
    /// Enters a random nickname into given textfield so user doesn't have to make up their own
    static func chooseRandomNickname(textField: UITextField) {
        let randomInt = Int.random(in: 0..<String.randomNicknames.count)
        textField.text = String.randomNicknames[randomInt]
    }
}

// MARK: - UIView

extension UIView {
  func performFlare() {
    func flare()   { transform = CGAffineTransform(scaleX: 1.1, y: 1.1) }
    func unflare() { transform = .identity }
    
    UIView.animate(withDuration: 0.3,
                   animations: { flare() },
                   completion: { _ in UIView.animate(withDuration: 0.2) { unflare() }})
  }
}

// MARK: - UIButton

extension UIButton {
    
    /// Takes in 2 colors, and applies a gradient to button
    func applyGradient(colors: [CGColor]) {
        
        self.backgroundColor = nil
        self.layoutIfNeeded()
        
        // Gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 15//self.frame.height / 2 // used to be 7.0
        
        // Shadow
        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.4
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
    }
}

// MARK: - Date

extension DateFormatter {
    
    /// Navigation Bar Date Label for PlantTableViewController and DetailViewController
    /// ENG: Friday 01/15 SPA: viernes 01/15
    /// dateFormat = "EEEE MM/d"
    static let navBarDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/d"
        return formatter
    }()
    
    /// Last Watered Date Label for NotepadViewController and ReminderViewController
    /// ENG: Friday 01/15/21, 10:47 AM SPA: viernes 01/15/21, 10:47 a. m.
    /// dateFormat = "EEEE MM/dd/yy, h:mm a"
    static let lastWateredDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd/yy, h:mm a"
        return formatter
    }()
    
    /// Time Label for PlantTableViewCell
    /// ENG: 10:00 AM SPA: 10:00 a. m.
    /// timeStyle = .short
    static let timeOnlyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Alarm Date Label for ReminderTableViewCell
    /// ENG: Jan 10, 2021 SPA: ene 10, 2021
    /// dateStyle = .medium
    static let dateOnlyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    /// Reminder Cell Right Swipe Action
    /// ENG:  SPA:
    /// dateStyle = .short, timeStyle  = .short
    static let shortTimeAndDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

extension UNUserNotificationCenter {
    
    /// Returns number of active notifications that are pending
    static func checkPendingNotes(completion: @escaping (Int) -> Void = { _ in }) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notes) in
            DispatchQueue.main.async {
                print("pending count = \(notes.count)")
                completion(notes.count)
            }
        }
    }
}

extension UIAlertController {
    
    /// Makes custom alerts for given ViewController with given title and message for error alerts
    static func makeAlert(title: String, message: String, vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}
