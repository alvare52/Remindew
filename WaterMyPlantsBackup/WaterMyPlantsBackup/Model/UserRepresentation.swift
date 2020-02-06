//
//  UserRepresentation.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation

struct UserRepresentation: Codable {
    var username: String
    var password: String
    var email: String
    var phone_number: Int
    var user_id: Int?
}
