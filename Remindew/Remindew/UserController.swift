//
//  UserController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

struct AllUsers: Codable {
    var users: [AllUser]
}

struct AllUser: Codable {
    let username: String
    let password: String
    let email: String
    let id: Int
    let phoneNumber: Int

    enum CodingKeys: String, CodingKey {
        case username, password, email
        case phoneNumber = "phone_number"
        case id
    }
}

struct LoginResponse: Codable {
    let message: String
    let user_id: Int
    let token: String
}

struct nameAndPassword: Codable {
    let username: String
    let password: String
}

var universal = LoginResponse(message: "test", user_id: 0, token: "")
var universalAllUsers: [AllUser] = []

struct TestUser: Codable {
    let username: String
    let password: String
    let email: String
    let id: String
    let phoneNumber: Int

    enum CodingKeys: String, CodingKey {
        case username, password, email
        case phoneNumber = "phone_number"
        case id
    }
}

let baseURL = URL(string: "https://water-my-plants-2.herokuapp.com/api")!
let fireBaseUrl = URL(string: "https://waterplantsfirebase.firebaseio.com/")!

class UserController {

    typealias CompletionHandler = (Error?) -> Void

    // MARK: - Properties
    
    // British colloquialism
    init() {
        print("INIT")
    }

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

    /// Delete a user from the server
    func deletePlantFromServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        // NEEDS to have ID
        guard let uuid = plant.identifier else {
            completion(NSError())
            return
        }

        let requestURL = fireBaseUrl.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)

            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }
    
    /// Saves to Core Data
    func savePlant() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
