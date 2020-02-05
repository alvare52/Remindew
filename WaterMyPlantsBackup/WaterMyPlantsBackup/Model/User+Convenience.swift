//
//  User+Convenience.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

extension User {
    
    // Turns Core Data Managed Task Object into a UserRepresentation for changing to JSON and sending to server
    var userRepresentation: UserRepresentation? {
        
        guard let username = username, let password = password, let email = email else {return nil}
        
        return UserRepresentation(username: username, password: password, email: email, phone_number: Int(phone_number))
    }
    
    // Creating a new managed object in Core Data
    @discardableResult convenience init(username: String,
                                        password: String,
                                        email: String,
                                        phone_number: Int,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.username = username
        self.password = password
        self.email = email
        self.phone_number = Int16(phone_number)
    }
    
    // Converting UserRepresentation (coming from JSON) into a managed object for Core Data
    @discardableResult convenience init?(userRepresentation: UserRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(username: userRepresentation.username,
                  password: userRepresentation.password,
                  email: userRepresentation.email,
                  phone_number: userRepresentation.phone_number,
                  context: context)
    }
    
    
}
