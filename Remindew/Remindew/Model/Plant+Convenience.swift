//
//  Plant+Convenience.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

extension Plant {
            
    /// Creating a new managed object in Core Data
    @discardableResult convenience init(nickname: String,
                                        species: String,
                                        water_schedule: Date,
                                        frequency: [Int16],
                                        needsWatering: Bool = false,
                                        lastDateWatered: Date? = nil,
                                        scientificName: String = "",
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.nickname = nickname
        self.species = species
        self.water_schedule = water_schedule
        self.frequency = frequency
        self.needsWatering = needsWatering
        self.lastDateWatered = lastDateWatered
        self.scientificName = scientificName
        self.identifier = identifier
    }
}

// Need to make warning go away but needs implementation
//@objc(FrequencyTransformer)
//class FrequencyTransformer : ValueTransformer {
// 
//}
