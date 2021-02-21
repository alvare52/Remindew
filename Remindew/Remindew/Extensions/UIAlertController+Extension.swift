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
    
    /// Presents an alert for missing text in species textfield. Clicks in species textfield when user clicks OK
    static func makeSpeciesAlert(textField: UITextField, vc: UIViewController) {
        
        let title = NSLocalizedString("Missing Plant Type",
                                      comment: "Title for when species name is missing in textfield")
        let message = NSLocalizedString("Please enter the type of plant you have.\nExample: \"Peace Lily\"",
                                        comment: "Message for when plant type name is missing in textfield")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            textField.becomeFirstResponder()
        }
        
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}
