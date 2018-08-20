//
//  GooglePlacesResult.swift
//  travelen
//
//  Created by rahul gupta on 4/13/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct GooglePlacesResult: Codable {
    var next_page_token: String?
    var results: [GooglePlacesList]?
}
