//
//  PlaceReviewTableViewCell.swift
//  travelen
//
//  Created by rahul gupta on 4/19/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit
import Cosmos

class PlaceReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewTexxLabel: UILabel!
    @IBOutlet weak var reviewRating: CosmosView!
    
    func setReview(_ review: GenericReview) {
        if let iconURL = review.user_profile_url {
            let url = URL(string: iconURL)!
            let iconData = try? Data(contentsOf: url)
            self.userImage.image = UIImage(data: iconData!)
        }
        
        self.userNameLabel.text = review.user_name
        self.dateLabel.text = review.time_created
        self.reviewTexxLabel.text = review.text
        self.reviewRating.rating = review.rating
    }
}
