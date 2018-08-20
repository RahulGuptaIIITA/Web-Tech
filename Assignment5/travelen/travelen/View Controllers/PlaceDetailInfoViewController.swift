//
//  PlaceDetailInfoViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit
import Cosmos
import Foundation

class PlaceDetailInfoViewController: UIViewController {

    var placeDetail: GooglePlaceDetailsInfo?
     
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var priceLevel: UILabel!
    @IBOutlet weak var googlePage: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var placeRating: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {

        if let detail = placeDetail {
            
            self.googlePage.text = "No XXX"
            self.website.text = "No XXX"
            self.address.text = detail.formatted_address
            self.phoneNumber.text = detail.international_phone_number != nil ? detail.international_phone_number : "No XXX"
            self.priceLevel.text = "Free"
            
            if let price_level = detail.price_level {
                
                var count = 0
                var price_string = ""
                repeat {
                    price_string += "$"
                    count += 1
                } while ( count < price_level )
                
                self.priceLevel.text = price_string
            }
            
            if placeDetail?.website != nil {
                self.website.text = detail.website
                let websiteTap = UITapGestureRecognizer(target: self, action: #selector(self.websiteUrl(sender:)))
                self.website.isUserInteractionEnabled = true
                self.website.addGestureRecognizer(websiteTap)
            }
            
            if placeDetail?.url != nil {
                self.googlePage.text = detail.url
                let googlepageTap = UITapGestureRecognizer(target: self, action: #selector(self.googlePageUrl(sender:)))
                self.googlePage.isUserInteractionEnabled = true
                self.googlePage.addGestureRecognizer(googlepageTap)
            }
            
            self.placeRating.rating = placeRating.rating
        }
    }
    
    @objc func websiteUrl(sender:UITapGestureRecognizer) {
        let url = placeDetail?.website
        openUrl(urlString: url)
    }
    
    @objc func googlePageUrl(sender:UITapGestureRecognizer) {
        let url = placeDetail?.url
        openUrl(urlString: url)
    }
    
    func openUrl(urlString:String!) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
