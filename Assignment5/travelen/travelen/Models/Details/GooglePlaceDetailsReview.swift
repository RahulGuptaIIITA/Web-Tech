//
//  GooglePlaceDetailsReview.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct GooglePlaceDetailsReview: Codable {
    var time: Int
    var rating: Double
    var text: String
    var author_url: String?
    var author_name: String
    var profile_photo_url: String?
}
