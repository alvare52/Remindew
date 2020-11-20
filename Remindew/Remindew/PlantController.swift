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
    
    // MARK: - Create, Read, Update, Delete Plants (Firebase API)

    /// Turns FireBase objects to Core Data objects
    private func updatePlants(with representations: [PlantRepresentation]) throws {
        // filter out the no ID ones
        let plantsWithID = representations.filter { $0.identifier != nil }

        // creates a new UUID based on the identifier of the task we're looking at (and it exists)
        // compactMap returns an array after it transforms
        let identifiersToFetch = plantsWithID.compactMap { $0.identifier! }

        // zip interweaves elements
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, plantsWithID))

        var plantsToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        // in order to be a part of the results (will only pull tasks that have a duplicate from fire base)
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        // create private queue context
        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.perform {
            do {
                let existingPlants = try context.fetch(fetchRequest)

                // updates local tasks with firebase tasks
                for plant in existingPlants {
                    // continue skips next iteration of for loop
                    guard let id = plant.identifier, let representation = representationsByID[id] else {continue}
                    self.update(plant: plant, with: representation)
                    plantsToCreate.removeValue(forKey: id)
                }

                for representation in plantsToCreate.values {
                    Plant(plantRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching plants for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: context)
    }

    /// Updates local user with data from the remote version (representation)
    private func update(plant: Plant, with representation: PlantRepresentation) {
        plant.nickname = representation.nickname
        plant.species = representation.species
        plant.frequency = Int16(representation.frequency)
        plant.water_schedule = representation.water_schedule
    }
    
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
