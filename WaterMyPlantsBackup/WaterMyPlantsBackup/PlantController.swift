//
//  PlantController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation
import CoreData
// Do I need this?
class PlantController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchPlantsFromServer()
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
