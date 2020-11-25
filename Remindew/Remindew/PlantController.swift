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
    
    /// Returns the Int that represents the next day for a reminder to go off
    func getNextDay(days: [Int]) -> Int {
        var result = 0
        var dayIndex = 0 // add to Plant model
        
        // There MUST be at least one day, so just increment by 7 days
        if days.count == 1 {
            result = 7
        }
        // At least 2 days [2,4,5]
        else {
            // if last day was last in array
            if dayIndex == days.count - 1 {
                dayIndex = 0
            }
            dayIndex += 1
            result = days[dayIndex]
        }
        
        return result
    }
}
