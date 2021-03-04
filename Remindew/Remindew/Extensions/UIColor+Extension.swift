//
//  UIColor+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/19/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    
    static let creamPink: UIColor = UIColor(red: 253.0 / 255.0, green: 168.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    static let mintGreen: UIColor = UIColor(red: 120.0 / 255.0, green: 190.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
    static let butterYellow: UIColor = UIColor(red: 241.0 / 255.0, green: 195.0 / 255.0, blue: 116.0 / 255.0, alpha: 1.0)
    static let eggshellWhite: UIColor = UIColor(red: 220.0 / 255.0, green: 220.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
    
    ///
    static let lightLeafGreen = UIColor(red: 104.0 / 255.0, green: 174.0 / 255.0, blue: 120.0 / 255.0, alpha: 1.0)
    
    /// Leaf Green. R: 104, G: 154, B: 100
    static let leafGreen = UIColor(red: 104.0 / 255.0, green: 154.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    
    ///
    static let darkLeafGreen = UIColor(red: 104.0 / 255.0, green: 144.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    ///
    static let darkWaterBlue = UIColor(red: 101.0 / 255.0, green: 129.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0)

    /// Water Blue. R: 101, G: 139, B: 154
    static let waterBlue = UIColor(red: 101.0 / 255.0, green: 139.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
    
    ///
    static let lightWaterBlue = UIColor(red: 101.0 / 255.0, green: 159.0 / 255.0, blue: 174.0 / 255.0, alpha: 1.0)
    
    /// Light Blue Green. R: 39, G: 118, B: 112
    static let lightBlueGreen = UIColor(red: 39.0 / 255.0, green: 118.0 / 255.0, blue: 112.0 / 255.0, alpha: 1.0)
    
    /// Mixed Blue Green. R: 39, G: 98, B: 92
    static let mixedBlueGreen = UIColor(red: 39.0 / 255.0, green: 98.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
    
    /// Dark Blue Green. R: 39, G: 78, B: 72
    static let darkBlueGreen = UIColor(red: 39.0 / 255.0, green: 78.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
    
    /// Light Background Gray. R: 36, G: 36, B: 40
    static let lightBackgroundGray = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    
    /// Light Background Gray. R: 36, G: 36, B: 40
    static let darkBackgroundGray = UIColor(red: 36.0 / 255.0, green: 36.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0)
    
    /// Light Gray for disabled button:. R: 28, G: 28, B: 30
    static let disabledGray = UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
    
    /// Off-white used for background of main page in light mode. R: 242, G: 242, B: 247
    static let lightModeBackgroundGray = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    
    /// Black/Off-White used for main background color: Black (0,0,0) - Off-White  (242,242,247)
    static let customBackgroundColor = UIColor.init(named: "customBackgroundColor")
    
    /// White/Dark-Gray used for plant table view cells: White (255,255,255) - Dark-Gray (28,28,30
    static let customCellColor = UIColor.init(named: "customCellColor")
    
    /// White/MediumGray used for time label in main table view: MediumGray(134,134,137) - White (255,255,255)
    static let customTimeLabelColor = UIColor.init(named: "customTimeLabelColor")
    
    /// MediumGray/Off-White used for disabled buttons detail view controller: DarkGray(28,28,30) - Off-White (242,242,247)
    static let customDisabledGrayColor = UIColor.init(named: "customDisabledGrayColor")
    
    /// darkGray / White color used for selected days: darkGray (84,84,84) - White (255,255,255)
    static let customSelectedDayColor = UIColor.init(named: "customSelectedDayColor")
    
    /// Light/Dark Gray color used in DatePicker bar. Also using for Reminder/Notepad UI Components so they match
    static let customComponentColor = UIColor.init(named: "customComponentColor")
    
    /// White/Cool Dark Gray for DetailVC background color
    static let customDetailBackgroundColor = UIColor.init(named: "customDetailBackgroundColor")
    
    /// Light/Dark Gray color used for CustomizationView in AppearanceViewController
    static let customAppearanceComponentColor = UIColor.init(named: "customAppearanceComponentColor")
    
    /// check the value of the "darkThemeOn" UserDefault to then update the app window
    func updateToDarkOrLightTheme() {
        // Dark Theme
        if UserDefaults.standard.bool(forKey: .darkThemeOn) {
            print("Dark Theme On in Switch")
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
        // Light Theme
        else {
            print("Light Theme On in Switch")
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
    }
    
    /// Colors used with colorIndex to set custom color
    static let colorsArray = [.mixedBlueGreen, .waterBlue, UIColor.systemRed, .creamPink, UIColor.systemPink, UIColor.systemOrange, UIColor.systemYellow, .butterYellow, UIColor.systemGreen, .leafGreen, .mintGreen, UIColor.systemBlue, UIColor.systemTeal, UIColor.systemIndigo, UIColor.systemPurple, UIColor.darkGray, UIColor.brown, .eggshellWhite]
}
