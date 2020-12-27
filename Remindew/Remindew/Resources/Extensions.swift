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

// Step 1
extension NSNotification.Name {
    
    /// Posts a notification that tells the main table view to check the watering status and update the table
    static let checkWateringStatus = NSNotification.Name("checkWateringStatus")
    
    /// Posts a notification that tells main table view to update its sort descriptors
    static let updateSortDescriptors = NSNotification.Name("updateSortDescriptors")
    
    /// Posts a notification that tells the 3 main view controllers to update their appearance
    static let updateAllViewControllerAppearance = NSNotification.Name("updateAllViewControllerAppearance")
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
    
    static let sunday = NSLocalizedString("Sun", comment: "Sunday abbreviated")
    static let monday = NSLocalizedString("Mon", comment: "Monday abbreviated")
    static let tuesday = NSLocalizedString("Tue", comment: "Tuesday abbreviated")
    static let wednesday = NSLocalizedString("Wed", comment: "Wednesday abbreviated")
    static let thursday = NSLocalizedString("Thu", comment: "Thursday abbreviated")
    static let friday = NSLocalizedString("Fri", comment: "Friday abbreviated")
    static let saturday = NSLocalizedString("Sat", comment: "Saturday abbreviated")
    
    /// Array of NSLocalizedStrings just for label purposes
    static let dayInitials = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
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

// MARK: - UIColor

extension UIColor {
    
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
}
    
// MARK: - UIImage

extension UIImage {
    
    /// App icon image to use throughout app when a default image is needed. UIImage(named: "plantslogoclear1024x1024")!
    static let logoImage = UIImage(named: "plantslogoclear1024x1024")!
    
    /// Takes in a UIImageView and gives the bottom half a clear/black gradient with the given opacity.
    /// - Parameter imageView: the UIImageView we want to give a bottom half gradient (imageView needs a frame)
    /// - Parameter opacity: the amount of transparency we want for the applied gradient
    static func applyLowerPortionGradient(imageView: UIImageView, opacity: Float = 0.5) {
        let gradient = CAGradientLayer()
        // frame should be just bottom half of imageView
        let chunk = imageView.bounds.height / CGFloat(2.0)
        // only apply gradient to bottom half of imageView
        let bottomHalf = CGRect(x: imageView.bounds.origin.x,
                                y: imageView.bounds.maxY - chunk,
                                width: imageView.bounds.width,
                                height: chunk)
        gradient.frame = bottomHalf
        // first color is top color, second color is bottom color
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        // add transparency to taste
        gradient.opacity = opacity
        imageView.layer.addSublayer(gradient)
    }
    
    /// Save image to documents directory, and remove old one if it exists and save new one
    /// - Parameter imageName: the name of an image that has been saved
    /// - Parameter image: the UIImage you want to save
    static func saveImage(imageName: String, image: UIImage) {
        print("saveImage")
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        print("\(image.size) IMAGE SIZE")
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
            print("Success saving image")
        } catch let error {
            print("error saving file with error", error)
        }

    }

    /// Takes in the name of a stored image and returns a UIImage or nil if it can't find one
    static func loadImageFromDiskWith(fileName: String) -> UIImage? {

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            print("Success loading image")
            return image
        }

        return nil
    }
    
    /// Deletes image in directory with given name in file path
    static func deleteImage(_ imageName: String) {
        print("deleteImage")
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
    }
    
    /// Resize image to given dimensions
     static func resizeImage(image: UIImage) -> UIImage {
        print("\(image.size) IMAGE STARTS AS THIS")
        let newWidth: CGFloat = 1024.0 // ? check if image is too big first, then scale down if need be
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("\(newImage!.size) IMAGE SIZE RESCALED TO THIS")
        return newImage!
    }
}
