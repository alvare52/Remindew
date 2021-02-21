//
//  UIAlertController+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/20/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    /// Makes custom alerts for given ViewController with given title and message for error alerts
    static func makeAlert(title: String, message: String, vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}
