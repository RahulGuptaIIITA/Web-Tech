//
//  FavoriteTableViewCell.swift
//  travelen
//
//  Created by rahul gupta on 4/20/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func setFavorite(_ favorite: GooglePlacesList) {
       
        nameLabel.text = favorite.name
        addressLabel.text = favorite.vicinity
        
        let iconUrl = URL(string: favorite.icon)
        let iconData = try? Data(contentsOf: iconUrl!)
        iconImageView.image = UIImage(data: iconData!)
    }
}


