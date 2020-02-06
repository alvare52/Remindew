//
//  UserController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://water-my-plants-2.herokuapp.com/api")!

class UserController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    var bearer: Bearer?
    
//    init() {
//        fetchPlantsFromServer()
//    }
    
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
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
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
            } catch {
                print("Error decoding bearer object in SignUp() : \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        print("fetchPlantsFromServer")
        //let requestURL = baseURL.appendingPathExtension("json")
    }
    
    private func updatePlants(with representations: [PlantRepresentation]) throws {
        print("updatePlants with representations")
    }
    
    private func update(plant: Plant, with representation: PlantRepresentation) {
        print("update plant with representation")
    }
    
    func sendPlantsToServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        print("sendPlantsToServer")
    }
    
    func deletePlantFromServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        print("deletePlantFromServer")
    }
}

