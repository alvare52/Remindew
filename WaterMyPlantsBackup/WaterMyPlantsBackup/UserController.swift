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

struct AllUsers: Codable {
    var users: [UserTest]?
}

struct UserTest: Codable {
    let id: Int?
    let username: String
    let password: String
    let email: String
    let phoneNumber: Int

    enum CodingKeys: String, CodingKey {
        case id, username, password, email
        case phoneNumber = "phone_number"
    }
}

//struct UserTest: Codable {
//    var id: Int
//    var username: String
//    var password: String
//    var email: String
//    var phone_number: Int
//}

let baseURL = URL(string: "https://water-my-plants-2.herokuapp.com/api")!

class UserController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    var bearer: Bearer?
    var userRep: UserRepresentation?
    var fetchedUser: UserRepresentation?
    var loginResponse: LoginResponse?
    var displayedUser: UserRepresentation?
    var userTest: UserTest?
    var allUsers: AllUsers?
    
    init() {
        print("INIT")
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
    
    /// Converts server objects into Core Data objects
    private func updateUser(with representations: [UserRepresentation]) throws {
        print("updatePlants with representations")
    }
    
    /// Updates local user with data from the remote version (representation)
    private func update(plant: Plant, with representation: PlantRepresentation) {
//        user.username = representation.username
//        user.password = representation.password
//        user.email = representation.email
//        user.phone_number = Int16(representation.phone_number)
    }
    
    /// Send a created or updated user the server
    func sendUserPlantsToServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        print("sendPlantsToServer")
    }
    
    /// Delete a user from the server
    func deletePlantFromServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        print("deletePlantFromServer")
    }
}

