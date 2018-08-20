//
//  PlacesListViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/13/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit
import SwiftSpinner

class PlacesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var TVPlaceList: UITableView!
    
    var index = 0
    var nextPageToken: String?
    let defaults = UserDefaults.standard
    var placesList: [GooglePlacesList] = []
    var httpClient: HTTPClient = HTTPClient()
    var combinedPlaceList: [[GooglePlacesList]] = []
    
    lazy var prevButton = {
        return UIBarButtonItem(title: "Prev", style:.plain, target: self, action: #selector(self.fetchPrevResults))
    }()
    
    lazy var nextButton = {
        return UIBarButtonItem(title: "Next", style:.plain, target: self, action: #selector(self.fetchNextResults))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.combinedPlaceList.append(placesList)
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Search Results"

        TVPlaceList.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isToolbarHidden = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = "Search Results"

        TVPlaceList.delegate = self
        TVPlaceList.dataSource = self
        
        var items: [UIBarButtonItem] = []
        
        if index > 0, index < 3 {
            prevButton.isEnabled = true
        } else {
            prevButton.isEnabled = false
        }
        
        if index < 2, placesList.count == 20 {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
        
        items = [prevButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil), nextButton]
        self.setToolbarItems(items, animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        TVPlaceList.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        
        if self.placesList.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            TVPlaceList.backgroundView = nil
            
        } else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Results"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            TVPlaceList.backgroundView  = noDataLabel
            TVPlaceList.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (placesList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlacesListTableViewCell
        
        let iconUrl = URL(string: placesList[indexPath.row].icon)
        let iconData = try? Data(contentsOf: iconUrl!)
        
        cell.delegate = self
        cell.icon.image = UIImage(data: iconData!)
        cell.name.text = placesList[indexPath.row].name
        cell.address.text = placesList[indexPath.row].vicinity
        
        if Utils.ifFavorite(outPlaceId: placesList[indexPath.row].placeId) {
            cell.favorite .setImage(#imageLiteral(resourceName: "favorite-filled"), for: .normal)
        } else {
            cell.favorite .setImage(#imageLiteral(resourceName: "favorite-empty"), for: .normal)
        }
        cell.indexPath = indexPath
        
        return (cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        SwiftSpinner.show("Fetching place details...")
        if let selectedPlace = indexPath?.row {
            let placeId: String = placesList[selectedPlace].placeId
            let placeIconUrl = placesList[selectedPlace].icon
            httpClient.fetchPlaceDetails(outPlaceId: placeId) { [weak self] (result, error) in
                if(error == nil) {
                    if let placeDetails = result?.result {
                        guard let tabController = self?.storyboard?.instantiateViewController(withIdentifier: "placeDetailViewController") as? PlaceDetailTabViewController else { return }
                        
                        tabController.placeDetail = placeDetails
                        tabController.placeIconUrl = placeIconUrl
                        SwiftSpinner.hide()
                        if let viewControllers = tabController.viewControllers {
                            if let infoVC = viewControllers[0] as? PlaceDetailInfoViewController {
                                infoVC.placeDetail = placeDetails
                            }
                            
                            if let infoVC = viewControllers[1] as? PlaceDetailPhotoViewController {
                                infoVC.placeDetail = placeDetails
                            }
                            
                            if let infoVC = viewControllers[2] as? PlaceDetailMapViewController {
                                infoVC.placeDetail = placeDetails
                            }
                            
                            if let infoVC = viewControllers[3] as? PlaceDetailReviewViewController {
                                infoVC.placeDetail = placeDetails
                            }
                        }
                        
                        self?.navigationController?.pushViewController(tabController, animated: true)
                    }
                }
                else {
                    print (error?.message)
                    print("Facing problem in fetching user's current location")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
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
    
    @objc func fetchPrevResults()
    {
        self.placesList = self.combinedPlaceList[self.index-1]
        self.index -= 1
        self.setupUI()
    }
    
    @objc func fetchNextResults()
    {
        SwiftSpinner.show("Loading next page...")
        if self.combinedPlaceList.count > self.index + 1 {
            self.placesList = self.combinedPlaceList[self.index+1]
            self.index += 1
            SwiftSpinner.hide()
            self.setupUI()
            
        } else {
            if let token = self.nextPageToken  {
                httpClient.fetchNextPageResult(outNextPageToken: token) { [weak self] (result, error) in
                    if(error == nil) {
                        if let newPlaceList = result?.results {
                            self?.nextPageToken = result?.next_page_token
                            self?.placesList = newPlaceList
                            self?.combinedPlaceList.append(newPlaceList)
                            self?.index += 1
                            SwiftSpinner.hide()
                            self?.setupUI()
                        }
                    } else {
                        print("Facing problem in fetching Next Page Data")
                    }
                }
            } else {
                print ("Next Page Token is Nil")
            }
        }
    }
}

extension PlacesListViewController: PlacesListTableViewCellDelegate {
    
    func didTapFavoriteButtonAtIndexPath(_ indexPath: IndexPath, outOperation opt: String) {
        let placeObject = placesList[indexPath.row]
                
        if opt == "add" {
            Utils.addPlaceToFavorite(placeObject)
            self.showToast(message: placeObject.name + " was added to favorites")
        } else {
            Utils.deleteFavoriteWithPlaceId(placeObject.placeId)
            self.showToast(message: placeObject.name + " was removed from favorites")
        }
    }
}
