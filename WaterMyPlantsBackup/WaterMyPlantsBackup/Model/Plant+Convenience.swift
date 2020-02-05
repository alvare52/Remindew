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
    
    // Turns Core Data Managed Task Object into a PlantRepresentation for changing to JSON and sending to server
    var plantRepresentation: PlantRepresentation? {
        
        guard let nickname = nickname, let species = species, let water_schedule = water_schedule else {return nil}
        
        return PlantRepresentation(nickname: nickname, species: species, water_schedule: water_schedule, last_watered: last_watered ?? Date(), frequency: Int(frequency), image_url: image_url, id: Int(id))
    }
    
    // Creating a new managed object in Core Data
    @discardableResult convenience init(nickname: String,
                                        species: String,
                                        water_schedule: Date,
                                        last_watered: Date?,
                                        frequency: Int = 0,
                                        image_url: String?,
                                        id: Int,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.nickname = nickname
        self.species = species
        self.water_schedule = water_schedule
        self.last_watered = last_watered
        self.frequency = Int16(frequency)
        self.image_url = image_url
        self.id = Int16(id)
    }
    
    // Converting PlantRepresentation (coming from JSON) into a managed object for Core Data
    @discardableResult convenience init?(plantRepresentation: PlantRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        // Maybe add guard lets later???
        self.init(nickname: plantRepresentation.nickname,
                  species: plantRepresentation.species,
                  water_schedule: plantRepresentation.water_schedule,
                  last_watered: plantRepresentation.last_watered,
                  frequency: plantRepresentation.frequency,
                  image_url: plantRepresentation.image_url,
                  id: plantRepresentation.id,
                  context: context)
    }
}
