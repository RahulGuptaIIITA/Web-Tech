//
//  GenericReview.swift
//  travelen
//
//  Created by rahul gupta on 4/19/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct GenericReview: Codable {
    var rating: Double
    var text: String
    var user_name: String
    var review_url: String?
    var time_created: String
    var user_profile_url: String?
}
