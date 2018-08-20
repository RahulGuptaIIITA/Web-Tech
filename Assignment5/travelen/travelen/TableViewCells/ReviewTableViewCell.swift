//
//  ReviewTableViewCell.swift
//  travelen
//
//  Created by rahul gupta on 4/18/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {


    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var reviewText: UITextField!
    @IBOutlet weak var reviewDate: UITextField!
    @IBOutlet weak var reviewRating: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
