//
//  PlantController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

class PlantController {
    
    // MARK: - Create, Read, Update, Delete, Save plants
    
    /// Create a plant and then save it
    func createPlant(nickname: String, species: String, date: Date, frequency: Int16) {
        _ = Plant(nickname: nickname, species: species, water_schedule: date, frequency: frequency)
        savePlant()
    }
    
    /// Update a plant that already exists
    func update(nickname: String, species: String, water_schedule: Date, frequency: Int16, plant: Plant) {
        plant.nickname = nickname
        plant.species = species
        plant.water_schedule = water_schedule
        plant.frequency = frequency
        savePlant()
    }
    
    /// Deletes plant and then saves or resets if there's an error
    func deletePlant(plant: Plant) {
        CoreDataStack.shared.mainContext.delete(plant)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset() // UN-deletes
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    /// Saves to Core Data, gets called from other methods
    func savePlant() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
