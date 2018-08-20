//
//  PlaceDetailTabViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit

class PlaceDetailTabViewController: UITabBarController {
    
    var didComeFromFavorites: Bool = false
    var placeIconUrl:String!
    var placeDetail: GooglePlaceDetailsInfo!
    var addFavButton: UIButton = UIButton(type: UIButtonType.custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(didComeFromFavorites == true) {
            super.viewDidAppear(animated)
            self.navigationController?.isToolbarHidden = true
        }
    }
    
    private func ifFavorite() -> Bool {
        let placeKey = "favorite_" + placeDetail.place_id
        for element in UserDefaults.standard.dictionaryRepresentation() {
            if element.key == placeKey {
                return true
            }
        }
        return false
    }
    
    private func setupUI() {
        
        // Setting the Buttons.
        if ifFavorite() {
            addFavButton.setImage(UIImage(named: "favorite-filled"), for: UIControlState.normal)
        } else {
            addFavButton.setImage(UIImage(named: "favorite-empty"), for: UIControlState.normal)
        }
        addFavButton.addTarget(self, action: #selector(addFavorite), for: UIControlEvents.touchUpInside)
        addFavButton.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
        
        let tweetButton: UIButton = UIButton(type: UIButtonType.custom)
        tweetButton.setImage(UIImage(named: "forward-arrow"), for: UIControlState.normal)
        tweetButton.addTarget(self, action: #selector(shareTweet), for: UIControlEvents.touchUpInside)
        tweetButton.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
        
        let favButton = UIBarButtonItem(customView: addFavButton)
        let twitterButton = UIBarButtonItem(customView: tweetButton)
        self.navigationItem.rightBarButtonItems = [favButton, twitterButton]
        
        // Setting the title.
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = placeDetail.name
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 250, width: self.view.frame.width - 60, height: 50))
        toastLabel.center.x = self.view.center.x;
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            toastLabel.removeFromSuperview();
        }
    }
    
    @objc func addFavorite() {
        if Utils.ifFavorite(outPlaceId: self.placeDetail.place_id) {
            Utils.deleteFavoriteWithPlaceId(placeDetail.place_id)
            addFavButton .setImage(#imageLiteral(resourceName: "favorite-empty"), for: .normal)
            self.showToast(message: placeDetail.name + " was removed from favorites")
        } else {
            addFavButton .setImage(#imageLiteral(resourceName: "favorite-filled"), for: .normal)
            let placeObject = GooglePlacesList(icon: self.placeIconUrl, name: placeDetail.name, placeId: placeDetail.place_id, vicinity: placeDetail.formatted_address!)
            Utils.addPlaceToFavorite(placeObject)
            self.showToast(message: placeDetail.name + " was added to favorites")
        }
    }
    
    @objc func shareTweet() {
        var text = "Check out " + placeDetail.name + " located    at " + placeDetail.formatted_address! + ". Website: "
        
        if placeDetail.website != nil {
            text = text + placeDetail.website!
        } else {
            text = text + placeDetail.url!
        }
        text = text + " #TravelAndEntertainmentSearch";
        
        var components = URLComponents(string: "http://twitter.com/intent/tweet?text=")!
        components.queryItems = [
            URLQueryItem(name: "text", value: text)
        ]
        
        let url = components.url!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}


