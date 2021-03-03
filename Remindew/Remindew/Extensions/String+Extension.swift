//
//  String+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/19/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

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
    
    /// Get/Set value of setting for using plant color on the plant's name label
    static let usePlantColorOnLabel = "usePlantColorOnLabel"
    
    /// Get/Set value of setting for hiding silenced plant icon
    static let hideSilencedIcon = "hideSilencedIcon"
    
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
                                            "Leshy", "Greenman", "Bud Dwyer", "Treebeard",
                                            "Cilan", "Milo", "Erika", "Gardenia", "Ramos"]
        
    /// Returns a random nickname String
    static func returnRandomNickname() -> String {
        
        let randomInt = Int.random(in: 0..<String.randomNicknames.count)
        return String.randomNicknames[randomInt]
    }
    
    // MARK: - Localized Strings
    
    /// Localized String for Nickname
    static let nicknameLocalizedString = NSLocalizedString("Nickname", comment: "plant nickname")
    
    /// Localized String for Type of plant
    static let typeOfPlantLocalizedString = NSLocalizedString("Type of plant", comment: "plant's type")
    
    /// Localized String for Water/Agua. Main action default
    static let waterLocalizedString = NSLocalizedString("Water", comment: "water, default main action")
    
    /// Localized String for Plant/Planta
    static let plantLocalizedString = NSLocalizedString("Plant", comment: "plant")
    
    /// Localized String for plant "name" if no name is given yet. Ex: One of your plants/ Una de sus plantas
    static let defaultPlantNameLocalizedString = NSLocalizedString("One of your plants", comment: "default plant name when none is given")
    
    /// Default Title for Plant's main action notification. Ex: "One of your plants needs attention." Localized
    static func defaultTitleString() -> String {
        return NSLocalizedString("One of your plants needs attention.", comment: "Message for notification")
    }
    
    /// Default Message for Plant's main action notification. Ex: "\(Name) needs \(action)." Localized
    static func defaultMessageString(name: String, action: String) -> String {
        return "\(name.capitalized)" + NSLocalizedString(" needs ", comment: "") + "\(action.lowercased())."
    }
}
