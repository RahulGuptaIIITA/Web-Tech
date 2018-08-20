//
//  PlaceDetailPhotoViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit
import Foundation

class PlaceDetailPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var placeDetail: GooglePlaceDetailsInfo?
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numOfSections: Int = 0
        
        guard let photo = placeDetail?.photos else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            noDataLabel.text          = "No Photos"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            collectionView.backgroundView  = noDataLabel
            
            return numOfSections
        }
        
        
        if photo.count > 0
        {
            numOfSections            =  photo.count
            collectionView.backgroundView = nil
        }
        
        
        return numOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionVC", for: indexPath) as! PhotoCollectionViewCell
    
        if let width = placeDetail?.photos![indexPath.row].width, let reference = placeDetail?.photos![indexPath.row].photo_reference {
            
            var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/photo")!
            components.queryItems = [
                URLQueryItem(name: "maxwidth", value: String(width)),
                URLQueryItem(name: "photoreference", value: reference),
                URLQueryItem(name: "key", value: "AIzaSyCBySLe96XKPFJr3NhJrpwaSMp_2inmaL4"),
            ]
            
            let photoURL = components.url!
            
            
            let photoData = try? Data(contentsOf: photoURL)
            cell.placePhoto.image = UIImage(data: photoData!)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print (placeDetail?.photos![indexPath.row].photo_reference! as Any)
    }
}

