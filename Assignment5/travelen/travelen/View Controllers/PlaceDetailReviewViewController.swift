//
//  PlaceDetailReviewViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

//  https://www.youtube.com/watch?v=CO93s3CmMiY

import UIKit
import Foundation

class PlaceDetailReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sortType: String = "Default"
    var orderType: String = "Ascending"
    var reviewType: String = "Google Reviews"
    var placeDetail: GooglePlaceDetailsInfo?
    
    var reviews = [GenericReview]()
    var httpClient: HTTPClient = HTTPClient()
    var yelpGenericReviews = [GenericReview]()
    var googleGenericReviews = [GenericReview]()
    
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        self.populateGoogleReviews()
        self.populateYelpReviews()
        self.setupUI()
    }
    
    private func populateGoogleReviews() {
        
        if let googleReviews = placeDetail?.reviews {
            for review in googleReviews {
                
                let date = Date(timeIntervalSince1970: TimeInterval(review.time))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
                let localDate = dateFormatter.string(from: date)
              
                let genericReview = GenericReview(rating: review.rating, text: review.text, user_name: review.author_name, review_url: review.author_url, time_created: localDate, user_profile_url: review.profile_photo_url)
                googleGenericReviews.append(genericReview)
            }
        }
    }
    
    private func populateYelpReviews() {
        var city:String = "";
        var name:String = "";
        var state:String = "";
        var country:String = "";
        var address:String = "";
        
        name = (self.placeDetail?.name)!
        address = (self.placeDetail?.formatted_address)!
  
        for component in (placeDetail?.address_components)!  {
            let types = component.types
            
            if (types.contains("country")) {
                country = component.short_name;
            }
            else if (types.contains("administrative_area_level_1")) {
                state = component.short_name;
            }
            else if (types.contains("administrative_area_level_2")) {
                city = component.short_name;
            }
        }

        httpClient.fetchYelpReviews(outName: name, outAddress: address, outCity: city, outState: state, outCountry: country) { [weak self] (result, error) in
            if(error == nil) {
                if let yelpReviews = result?.reviews {
                    for review in yelpReviews {
                        let genericReview = GenericReview(rating: Double(review.rating), text: review.text, user_name: review.user.name, review_url: review.url, time_created: String(describing: review.time_created), user_profile_url: review.user.image_url)
                        self?.yelpGenericReviews.append(genericReview)
                    }
                }
            } else {
                print("Zero Yelp Reviews Found")
            }
        }
    }
    
    private func compareRatingAscending(s1:GenericReview, s2:GenericReview) -> Bool {
        return s1.rating < s2.rating
    }
    
    private func compareRatingDescending(s1:GenericReview, s2:GenericReview) -> Bool {
        return s1.rating > s2.rating
    }
    
    private func compareTimeAscending(s1:GenericReview, s2:GenericReview) -> Bool {
        return s1.time_created < s2.time_created
    }
    
    private func compareTimeDescending(s1:GenericReview, s2:GenericReview) -> Bool {
        return s1.time_created > s2.time_created
    }
    
    private func setupUI() {

        reviews = googleGenericReviews
        if reviewType == "Yelp Reviews" {
            reviews = yelpGenericReviews
        }
        
        if sortType == "Rating" {
            if orderType == "Ascending" {
                reviews = self.reviews.sorted(by: compareRatingAscending)
            } else {
                reviews = self.reviews.sorted(by: compareRatingDescending)
            }
        }
        else if sortType == "Date" {
            if orderType == "Ascending" {
                reviews = self.reviews.sorted(by: compareTimeAscending)
            } else {
                reviews = self.reviews.sorted(by: compareTimeDescending)
            }
        }
        reviewTableView.reloadData()
    }
    
    @IBAction func sortType(_ sender: UISegmentedControl) {
        sortType = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        self.setupUI()
    }
    
    @IBAction func orderType(_ sender: UISegmentedControl) {
        orderType = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        self.setupUI()
    }
    
    @IBAction func reviewType(_ sender: UISegmentedControl) {
        reviewType = sender.titleForSegment(at: sender.selectedSegmentIndex)!
 
        self.setupUI()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        
        if self.reviews.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
            
        } else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Reviews"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceReviewTableViewCell", for: indexPath) as! PlaceReviewTableViewCell
        
        if indexPath.row >= 0 {
            cell.setReview(reviews[indexPath.row])
        }
        
        return (cell)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        if let selectedPlace = indexPath?.row {
            if let profileURL = reviews[selectedPlace].review_url {
                let components = URLComponents(string: profileURL)!
                let url = components.url!
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            else {
                //
            }
        }
    }
}
