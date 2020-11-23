//
//  Extensions.swift
//  Remindew
//
//  Created by Jorge Alvarez on 11/20/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

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
        gradientLayer.cornerRadius = 7.0 //self.frame.height / 2
        
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
    
    /// Leaf Green. R: 104, G: 154, B: 100
    static let leafGreen = UIColor(red: 104.0 / 255.0, green: 154.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    
    /// Water Blue. R: 101, G: 139, B: 154
    static let waterBlue = UIColor(red: 101.0 / 255.0, green: 139.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
    
    /// Mixed Blue Green. R: 39, G: 98, B: 92
    static let mixedBlueGreen = UIColor(red: 39.0 / 255.0, green: 98.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
    
    /// Light Blue Green. R: 39, G: 118, B: 112
    static let lightBlueGreen = UIColor(red: 39.0 / 255.0, green: 118.0 / 255.0, blue: 112.0 / 255.0, alpha: 1.0)
    
    /// Dark Blue Green. R: 39, G: 78, B: 72
    static let darkBlueGreen = UIColor(red: 39.0 / 255.0, green: 78.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
}
