//
//  DateFormatter+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/20/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation

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
