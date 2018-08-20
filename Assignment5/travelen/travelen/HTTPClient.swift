//
//  HTTPClient.swift
//  travelen
//
//  Created by rahul gupta on 4/11/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import Foundation

struct APIError {
    let code: Int
    let message: String?
}

class HTTPClient {
    
    func fetchRoute(outSource source: String, outDestination destinaton: String, outMode mode: String, completionHandler: @escaping ((GoogleDirections?, APIError?) -> ())) {
        
        print (mode)
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/directions/json?")!
        components.queryItems = [
            URLQueryItem(name: "origin", value: source),
            URLQueryItem(name: "destination", value: destinaton),
            URLQueryItem(name: "mode", value: mode),
            URLQueryItem(name: "key", value: "AIzaSyBWe2U2g6Q7ExMTzNDsI7T52h-gXgoqsJ4")
        ]
        let request = URLRequest(url: components.url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: error?.localizedDescription))
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Data was nil"))
                }
                return
            }
            
            do {
                let results = try JSONDecoder().decode(GoogleDirections.self, from: data)
                print (results.routes![0].overview_polyline.points)
                print ("here")
                DispatchQueue.main.async {
                    completionHandler(results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Error in parsing response"))
                }
            }
        }.resume()
    }
    
    func fetchGeoCordinates(outAddress address: String, completionHandler: @escaping ((GoogleGecodeResult?, APIError?) -> ())) {
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json?")!
        components.queryItems = [
            URLQueryItem(name: "address", value: address),
            URLQueryItem(name: "key", value: "AIzaSyBzyGygrjfuyoK_UAY2rdvHyCwEVz080lc")
        ]
        let request = URLRequest(url: components.url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: error?.localizedDescription))
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Data was nil"))
                }
                return
            }
            
            do {
                let results = try JSONDecoder().decode(GoogleGecodeResult.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Error in parsing response"))
                }
            }
        }.resume()
    }
    
    func fetchPlacesResult(outKeyword kw: String, outCateggory cg: String, outLat lat: Double, outLon lon: Double, outDistance dist: String, outCustomLoc customLoc: String, completionHandler: @escaping ((GooglePlacesResult?, APIError?) -> ())) {
        
        let dis = Int(dist)! * 1609
        let json = [
            "keyword": kw,
            "category": cg,
            "latitude": lat,
            "distance": dis,
            "longitude": lon,
            "customLoc": customLoc
            
        ] as [String : Any]
        
        let url = URL(string: "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/place")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {return}
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: error?.localizedDescription))
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Data was nil"))
                }
                return
            }

            do {
                let results = try JSONDecoder().decode(GooglePlacesResult.self, from: data)

                DispatchQueue.main.async {
                    completionHandler(results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Error in parsing response"))
                }
            }
        }.resume()
    }
    
    func fetchPlaceDetails(outPlaceId placeId: String, completionHandler: @escaping ((GooglePlaceDetails?, APIError?) -> ())) {
      
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/details/json?")!
        components.queryItems = [
            URLQueryItem(name: "placeid", value: placeId),
            URLQueryItem(name: "key", value: "AIzaSyBtmEELahaeYDE5q7cHDYKs-j6yeL2JewM")
        ]
        let request = URLRequest(url: components.url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: error?.localizedDescription))
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Data was nil"))
                }
                return
            }
            
            do {
                let results = try JSONDecoder().decode(GooglePlaceDetails.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Error in parsing response"))
                }
            }
        }.resume()
    }
    
    func fetchYelpReviews(outName name: String, outAddress address: String, outCity city: String, outState state: String, outCountry country: String, completionHandler: @escaping ((yelpReviews?, APIError?) -> ())) {

        let json = [
            "name": name,
            "city": city,
            "state": state,
            "country": country,
            "address": address
        ]
        
        let url = URL(string: "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/loadYelpReviews")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {return}
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: error?.localizedDescription))
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Data was nil"))
                }
                return
            }

            do {
                let results = try JSONDecoder().decode(yelpReviews.self, from: data)

                DispatchQueue.main.async {
                    completionHandler(results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Error in parsing response"))
                }
            }
        }.resume()
    }
    
    func fetchNextPageResult(outNextPageToken token: String, completionHandler: @escaping ((GooglePlacesResult?, APIError?) -> ())) {

        let json = [
            "token": token,
            
            ] as [String : Any]
        
        let url = URL(string: "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/loadNextPageData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {return}
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: error?.localizedDescription))
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Data was nil"))
                }
                return
            }
            
            do {
                print (data)
                let results = try JSONDecoder().decode(GooglePlacesResult.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(results, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, APIError(code: 999, message: "Error in parsing response"))
                }
            }
        }.resume()
    }
}
