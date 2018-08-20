//
//  review.swift
//  travelen
//
//  Created by rahul gupta on 4/18/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct reviews: Codable {
    var user: user
    var rating: Double
    var url: String
    var text: String
    var time_created: String
    
}
