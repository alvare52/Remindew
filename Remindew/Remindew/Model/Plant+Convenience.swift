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
    
    // Turns Core Data Managed Plant Object into a PlantRepresentation for changing to JSON and sending to server
    var plantRepresentation: PlantRepresentation? {
        
        guard let nickname = nickname, let species = species, let water_schedule = water_schedule else {return nil}
        
        return PlantRepresentation(frequency: Int(frequency), identifier: identifier, nickname: nickname, species: species, water_schedule: water_schedule)
    }
    
    /// Creating a new managed object in Core Data
    @discardableResult convenience init(nickname: String,
                                        species: String,
                                        water_schedule: Date,
                                        frequency: Int16,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.nickname = nickname
        self.species = species
        self.water_schedule = water_schedule
        self.frequency = Int16(frequency)
        self.identifier = identifier
    }
    
    /// Failable - Converting PlantRepresentation (coming from JSON) into a managed object for Core Data
    @discardableResult convenience init?(plantRepresentation: PlantRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        
        guard let identifier = plantRepresentation.identifier else {return nil}
        
        self.init(nickname: plantRepresentation.nickname,
                  species: plantRepresentation.species,
                  water_schedule: plantRepresentation.water_schedule,
                  frequency: Int16(plantRepresentation.frequency),
                  identifier: identifier,
                  context: context)
    }
}
