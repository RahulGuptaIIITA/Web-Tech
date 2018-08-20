//
//  PlacesListCellViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/13/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit

protocol PlacesListTableViewCellDelegate: class {
    func didTapFavoriteButtonAtIndexPath(_ indexPath: IndexPath, outOperation opt: String)
}

class PlacesListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var favorite: UIButton!
    
    var indexPath = IndexPath()
    weak var delegate: PlacesListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func favorite(_ sender: Any) {
        if let delegate = self.delegate {
            
            if favorite.imageView?.image  == #imageLiteral(resourceName: "favorite-empty") {
                favorite .setImage(#imageLiteral(resourceName: "favorite-filled"), for: .normal)
                delegate.didTapFavoriteButtonAtIndexPath(self.indexPath, outOperation: "add")
                
            } else {
                favorite .setImage(#imageLiteral(resourceName: "favorite-empty"), for: .normal)
                delegate.didTapFavoriteButtonAtIndexPath(self.indexPath, outOperation: "remove")
            }
        }
    }
}
