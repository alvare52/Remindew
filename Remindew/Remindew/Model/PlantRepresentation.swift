//
//  PlantRepresentation.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation

struct PlantRepresentation: Codable {
    var frequency: Int // Int16 CoreDataModel
    var identifier: UUID?
    var nickname: String
    var species: String
    var water_schedule: Date
}
