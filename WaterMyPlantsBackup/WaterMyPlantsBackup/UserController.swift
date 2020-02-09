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

// universal user credentials (I know this is bad)
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
    
    // Stores bearer token only (not needed anymore)
    var bearer: Bearer?
    
    //var userRep: UserRepresentation
    var fetchedUser: UserRepresentation?
    
    // Stores token and user id when signing in or logging in
    var loginResponse: LoginResponse?
    
    // Fetches plants from firebase when it's initialized
    init() {
        print("INIT")
        fetchPlantsFromServer()
    }

    // MARK: - Register, Log in, and Update User (Heroku API)
    
    /// Pass in a UserRepresentation object, posts it and receives a bearer token and user id
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
    
    /// Log in a user and receives token with user id)
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
            print("MADE IT PASSED THE RESPONSE IN LOG IN() usercontroller")
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
                
                print("LoginResponse.token: \(self.loginResponse?.token ?? "NO TOKEN")")
                print("LoginResponse.message: \(self.loginResponse?.message ?? "NO MESSAGE")")
                print("LoginResponse.user_id: \(self.loginResponse?.user_id ?? 666)")
                print("Should be logged in, token received: \(self.bearer?.token ?? "no token with log in")")
                // i know this is bad to do
                universal = self.loginResponse!
                print("UNIVERSAL -> \(universal)")
            } catch {
                print("Error decoding bearer object in logIn() : \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
        
    }
    
    /// Update a user (requires token and user id)
    func updateUser(userRep: UserRepresentation, creds: LoginResponse, completion: @escaping (Error?) -> Void) {
        print("called updateUser")
        // AUTHORIZATION
//        print(loginResponse?.token)
//        guard let loginResponse = self.loginResponse else {
//            print("Error with bearer in updateUser()")
//            completion(NSError())
//            return
//        }
        let toke = creds.token
        let userId = creds.user_id
        //let toke = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjYsInVzZXJuYW1lIjoiam9yZ2UiLCJpYXQiOjE1ODEyMTAxMjAsImV4cCI6MTU4MTI5NjUyMH0.XTQuva07-NJVbgj1i150Ph9usilO_zt83T4MNPEDqAM"
        //let userId = 6
        //let testRep = UserRepresentation(username: "jorge7", password: "alvarez7", email: "email7", phone_number: 8888888)
        
        // ENDPOINT + HEADERS
        let updateUrl = baseURL.appendingPathComponent("users/\(userId)")
        print(updateUrl)
        var request = URLRequest(url: updateUrl)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(toke)", forHTTPHeaderField: "Authorization")
        
        // ENCODE USER REP (4 props)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(userRep)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user rep object in update(): \(error)")
            completion(error)
            return
        }
        
        // OPEN BROWSER
        URLSession.shared.dataTask(with: request) { (data, response, error) in
          
            // 200 means success
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                print("no data in updateUser()")
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let updatedUser = try decoder.decode(TestUser.self, from: data)
                print("Updated user now: \(updatedUser)")
            } catch {
                print("Error decoding updating user object in updateUser(): \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    /// View all users to check if updating user worked in real time
    func viewAllUsers(userRep: UserRepresentation, creds: LoginResponse, completion: @escaping (Error?) -> Void) {
        print("called viewAllUsers")
        let toke = creds.token
        
        // ENDPOINT + HEADERS
        let viewAllUrl = baseURL.appendingPathComponent("users")
        
        var request = URLRequest(url: viewAllUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(toke)", forHTTPHeaderField: "Authorization")
        
        // OPEN BROWSER
        URLSession.shared.dataTask(with: request) { (data, response, error) in
          
            // 200 means success
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                print("no data in updateUser()")
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let allUsers = try decoder.decode([AllUser].self, from: data)
                for user in allUsers {
                    print(user.username)
                }
                universalAllUsers = allUsers
                print("universalAllUsers after = allUsers in decode: \(universalAllUsers)")
            } catch {
                print("Error decoding updating user object in updateUser(): \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - Create, Read, Update, Delete Plants (Firebase API)
    
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
    
    /// Saves to Core Data
    func savePlant() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    /// Update a plant that already exists
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

