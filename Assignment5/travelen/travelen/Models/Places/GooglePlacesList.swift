//
//  GooglePlacesList.swift
//  travelen
//
//  Created by rahul gupta on 4/13/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct GooglePlacesList: Codable {
    var icon: String
    var name: String
    var placeId: String
    var vicinity: String
    
    private enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        
        case icon
        case name
        case vicinity
    }
}
