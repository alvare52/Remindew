//
//  UIView+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/20/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func performFlare() {
    
    func flare() {
        transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    
    func unflare() { transform = .identity }
    
    UIView.animate(withDuration: 0.3,
                   animations: { flare() },
                   completion: { _ in UIView.animate(withDuration: 0.2) { unflare() }})
  }
}
