//
//  UserController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

struct LoginResponse: Codable {
    let message: String
    let user_id: Int
    let token: String
}

let baseURL = URL(string: "https://water-my-plants-2.herokuapp.com/api")!
let fireBaseUrl = URL(string: "https://waterplantsfirebase.firebaseio.com/")!

class UserController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    var bearer: Bearer?
    var userRep: UserRepresentation?
    var fetchedUser: UserRepresentation?
    var loginResponse: LoginResponse?
    
    init() {
        print("INIT")
        fetchPlantsFromServer()
    }
    
    /// Connect to Firebase
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseUrl.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching plants: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            do {
                let plantRepresentations = Array(try jsonDecoder.decode([String: PlantRepresentation].self, from: data).values)
                try self.updatePlants(with: plantRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding or storing plant representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            
        }.resume()
    }
    
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
    
    /// Pass in a UserRepresentation object, posts it and receives a bearer token
    func signUp(userRep: UserRepresentation, completion: @escaping (Error?) -> Void ) {
        
        let signUpUrl = baseURL.appendingPathComponent("auth/register")
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(userRep)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user rep object in SignUp() : \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse, response.statusCode != 201 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
                print("UserController.bearer = \(self.bearer?.token ?? "no token with sign in")")
            } catch {
                print("Error decoding bearer object in SignUp() : \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    /// Log in a user
    func logIn(userRep: UserRepresentation, completion: @escaping (Error?) -> Void ) {
        
        let loginUrl = baseURL.appendingPathComponent("auth/login")
        var request = URLRequest(url: loginUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(userRep)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user rep object in logIn(): \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                print("no data in logIn()")
                completion(NSError())
                return
            }
            
            print("DATA RECEIVED: \(data)")
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
                self.loginResponse = try decoder.decode(LoginResponse.self, from: data)
                print("LoginResponse: \(self.loginResponse?.token ?? "NO TOKEN")")
                print("LoginResponse: \(self.loginResponse?.message ?? "NO MESSAGE")")
                print("LoginResponse: \(self.loginResponse?.user_id ?? 666)")
                print("Should be logged in, token received: \(self.bearer?.token ?? "no token with log in")")
            } catch {
                print("Error decoding bearer object in logIn() : \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    /// Updates local user with data from the remote version (representation)
    private func update(plant: Plant, with representation: PlantRepresentation) {
        plant.nickname = representation.nickname
        plant.species = representation.species
        plant.frequency = Int16(representation.frequency)
        plant.water_schedule = representation.water_schedule
    }
    
    /// Send a created or updated plant to the server
    func sendPlantToServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = plant.identifier ?? UUID()
        let requestURL = fireBaseUrl.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        print("requestURL = \(requestURL)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT" // post ADDS to db (can add copies), "put" also finds recored and overrides it, or just adds
        
        // Encode data
        do {
            guard var representation = plant.plantRepresentation else {
                completion(NSError())
                return
            }
            // Both have same uuid
            representation.identifier = uuid
            plant.identifier = uuid
            try CoreDataStack.shared.save()
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            
            request.httpBody = try jsonEncoder.encode(representation)
        } catch {
            print("Error encoding plant \(plant): \(error)")
            DispatchQueue.main.async {
                completion(error)
            }
            return
        }
        // Send to server
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("error putting plant to server: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            // success
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    func savePlant() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func update(nickname: String, species: String, water_schedule: Date, frequency: Int16, plant: Plant) {
        plant.nickname = nickname
        plant.species = species
        plant.water_schedule = water_schedule
        plant.frequency = frequency
        sendPlantToServer(plant: plant)
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
}

