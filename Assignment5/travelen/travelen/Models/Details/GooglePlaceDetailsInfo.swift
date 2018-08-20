//
//  GooglePlaceDetailsInfo.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct GooglePlaceDetailsInfo: Codable {
    var name: String
    var url: String?
    var rating: Double?
    var place_id: String
    var website: String?
    var price_level: Int?
    var formatted_address: String?
    var international_phone_number: String?
    
    var geometry: GoogleGecodeLocation?
    var photos: [GooglePlaceDetailsPhoto]?
    var reviews: [GooglePlaceDetailsReview]?
    var address_components: [GooglePlaceDetailsAddressComponent]?
}
