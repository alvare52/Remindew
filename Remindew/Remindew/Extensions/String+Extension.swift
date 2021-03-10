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
    
    // MARK: - User Default Keys
    
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
    
    /// Get/Set value of setting for using bigger images in table view cell
    static let useBiggerImages = "useBiggerImages"
    
    /// Get/Set value of bool that checks if user has already been asked to allow Camera Usage. Should only be set to true and thats it
    static let alreadyAskedForCameraUsage = "alreadyAskedForCameraUsage"
    
    // MARK: - Helpers
    
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
    
    /// Localized String for Reminder Limit Alert Title
    static let reminderLimitTitleLocalizedString = NSLocalizedString("Reached Reminders Limit", comment: "reached reminder limit title")
    
    /// Localized String for Reminder Limit Alert Message
    static let reminderLimitMessageLocalizedString = NSLocalizedString("You've reached your limit of reminders for this plant", comment: "reached reminder limit message")
    
    /// Localized String for Plant Limit Alert Title
    static let plantLimitTitleLocalizedString = NSLocalizedString("Reached Plant Limit", comment: "reached plant limit title")
    
    /// Localized String for Plant Limit Alert Message
    static let plantLimitMessageLocalizedString = NSLocalizedString("Sorry, you've reached the limit of how many plants you can make.", comment: "reached plant limit message")
    
    /// Localized String for Appearance section description
    static let appearanceSectionLocalizedDescription = NSLocalizedString("Light/Dark theme are independent of phone settings. Main screen displays plant icon instead of image by default.", comment: "description for appearance section")
    
    /// Localized String for Main Label section description
    static let mainLabelSectionLocalizedDescription = NSLocalizedString("Top label displays nickname by default. Label color is dark green instead of selected color by default.", comment: "description for main label section")
    
    /// Localized String for Searches section description
    static let searchesSectionLocalizedDescription = NSLocalizedString("Clicking on a search result will replace plant type name with common name of selected result. Search by tapping \"search\" on keyboard when entering plant's type", comment: "description for searches section")
    
    /// Localized String for Trefle section description
    static let trefleSectionLocalizedDescription = NSLocalizedString("Trefle aims to increase awareness and understanding of living plants by gathering, generating and sharing knowledge in an open, freely accessible and trusted digital resource.", comment: "description for trefle section")
    
    /// Localized String for Default Plant Image section description
    static let defaultImageSectionLocalizedDescription = NSLocalizedString(NSLocalizedString("Default plant photo provided by Richard Alfonzo.", comment: "photo source description"), comment: "description for default image section")
    
    /// Localized String for Take Photo
    static let takePhotoLocalizedString = NSLocalizedString("  Take Photo", comment: "take photo button title")
    
    /// Localized String for Choose Photo
    static let choosePhotoLocalizedString = NSLocalizedString("  Choose Photo", comment: "choose photo button title")
    
    /// Localized String for Save Photo
    static let savePhotoLocalizedString = NSLocalizedString("  Save Photo", comment: "save photo button title")
    
    /// Localized String for Nickname
    static let nicknameLocalizedString = NSLocalizedString("Nickname", comment: "plant nickname")
    
    /// Localized String for Type of plant
    static let typeOfPlantLocalizedString = NSLocalizedString("Type of plant", comment: "plant's type")
    
    /// Localized String for Water/Agua. Main action default
    static let waterLocalizedString = NSLocalizedString("Water", comment: "water, default main action")
    
    /// Localized String for water/agua (noun).
    static let waterNounLocalizedString = NSLocalizedString("water", comment: "water, as a noun")
    
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
    
    /// Returns Localized String for title of Water All Plants alert including the number of plants that need water
    static func returnWaterAllPlantsLocalizedString(count: Int) -> String {
        
        let water = NSLocalizedString("Water", comment: "water")
        let plants = NSLocalizedString("Plants", comment: "plants")
        let plant = NSLocalizedString("Plant", comment: "plant")
        
        return count == 1 ? water + " \(count) " + plant : water + " \(count) " + plants
    }
}
