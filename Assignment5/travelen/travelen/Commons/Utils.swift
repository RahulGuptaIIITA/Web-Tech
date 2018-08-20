//
//  Utils.swift
//  travelen
//
//  Created by rahul gupta on 4/23/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func ifFavorite(outPlaceId placeId: String) -> Bool {
        let placeKey = "favorite_" + placeId
        for element in UserDefaults.standard.dictionaryRepresentation() {
            if element.key == placeKey {
                return true
            }
        }
        return false
    }
    
    static func deleteFavoriteWithPlaceId(_ placeId: String) {
        let placeKey = "favorite_" + placeId
        
        if let _ = UserDefaults.standard.dictionaryRepresentation()[placeKey] {
            UserDefaults.standard.removeObject(forKey: placeKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didModifyFavorites"), object: nil)
        }
    }
    
    static func addPlaceToFavorite(_ placeObject: GooglePlacesList) {
        var dict = [String : String]()
        dict = [ "name": placeObject.name, "icon": placeObject.icon, "place_id": placeObject.placeId, "address": placeObject.vicinity]
        UserDefaults.standard.set(dict, forKey: "favorite_" + placeObject.placeId)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didModifyFavorites"), object: nil)
    }
}
