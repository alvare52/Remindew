//
//  UIImage+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/19/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /// Memory cache to store already saved user plant images, clears itself after it has more than 100(?) images
    static var savedUserPlantImages = [String: UIImage]() {
        didSet {
            // clear cache after 100 images are stored
            if savedUserPlantImages.count > 100 {
                savedUserPlantImages.removeAll()
            }
        }
    }
    
    /// Icons used for actions
    static let iconArray = [UIImage(systemName: "drop.fill"), UIImage(systemName: "cross.fill"), UIImage(systemName: "ant.fill"), UIImage(systemName: "scissors"), UIImage(systemName: "aqi.low"), UIImage(systemName: "rotate.right.fill"), UIImage(systemName: "arrow.up.bin.fill"), UIImage(systemName: "circle.fill"), UIImage(systemName: "leaf.fill")]
    
    /// Icons used for plants
    static let plantIconArray = [UIImage(systemName: "leaf.fill"), UIImage(named: "planticonleaf")]
    
    /// App icon image to use throughout app when a default image is needed. UIImage(named: "plantslogoclear1024x1024")!
    static let logoImage = UIImage(named: "plantslogoclear1024x1024")!
    
    /// 60x60 version of app icon (clear background). UIImage(named: "plantslogoclear60x60")
    static let smallAppIconImage = UIImage(named: "plantslogo60x60")
    
    /// Psuedo SF Symbol version of leaf/drop icon that uses tintColor (can be used if system button option is not available)
    static let leafdropIcon = UIImage(named: "planticonleaf")!.withRenderingMode(.alwaysTemplate)
    
    /// Image used when no photo is given
    static let defaultImage = UIImage(named: "RemindewDefaultImage")
    
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
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
                // remove from savedUserPlantImages
                savedUserPlantImages.removeValue(forKey: imageName)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
            print("Success saving image")
            // add to cache of user's saved images for fast loading in main tableview
            savedUserPlantImages[imageName] = image
        } catch let error {
            print("error saving file with error", error)
        }

    }

    /// Takes in the name of a stored image and returns a UIImage or nil if it can't find one
    static func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        // First check savedUserPlantImages cache and return early
        if let imageFromCache = savedUserPlantImages[fileName] {
            return imageFromCache
        }
                
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            // put in cache so we can skip this next time
            savedUserPlantImages[fileName] = image
            return image
        }

        return nil
    }
    
    /// Deletes image in directory with given name in file path
    static func deleteImage(_ imageName: String) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
                // remove from savedUserPlantImages
                savedUserPlantImages.removeValue(forKey: imageName)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
    }
    
    /// Resize image to given dimensions
     static func resizeImage(image: UIImage) -> UIImage {
        
        let newWidth: CGFloat = 1024.0 // ? check if image is too big first, then scale down if need be
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
