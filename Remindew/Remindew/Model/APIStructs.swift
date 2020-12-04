//
//  APIStructs.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import Foundation

/// Main response from API call, holds the PlantSearchResult structs we want
struct PlantData: Decodable {
    let data: [PlantSearchResult]
}

/// API version of plant we want
struct PlantSearchResult: Decodable {
    
    /// So we can still use camel casing
    enum CodingKeys: String, CodingKey {
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case imageUrl = "image_url"
    }
    
    /// "Peace Lily"
    let commonName: String?
    
    /// Spathiphyllum floribundum
    let scientificName: String?
    
    /// "https://bs.floristic.org/image/o/4b5d9bab278879892ab945b84b7f5b24c8edca6f"
    let imageUrl: URL?
}

/// Client-side temporary token we want to grab everyday
struct TempToken: Decodable {
    
    /// Temporary token we'll use for API calls
    let token: String?
    
    /// Date (in String form) of when temporary token will expire (typically 24 hours)
    let expiration: String?
}
