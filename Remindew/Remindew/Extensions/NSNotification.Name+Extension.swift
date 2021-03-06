//
//  NSNotification.Name+Extension.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/20/21.
//  Copyright © 2021 Jorge Alvarez. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    
    /// Posts a notification that tells the main table view to check the watering status and update the table
    static let checkWateringStatus = NSNotification.Name("checkWateringStatus")
    
    /// Posts a notification that tells main table view to update its sort descriptors
    static let updateSortDescriptors = NSNotification.Name("updateSortDescriptors")
    
    /// Posts a notification that tells main table view to lay out its subviews again
    static let updateImageSizes = NSNotification.Name("updateImageSizes")
}
