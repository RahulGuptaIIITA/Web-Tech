//
//  ViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/10/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import SwiftSpinner

class HomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, GMSMapViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    var latitude: Double!
    var longitude: Double!
    var nextPageToken: String?
    var PVCategory: UIPickerView!
    var homeSeg: String = "SEARCH "
    let defaults = UserDefaults.standard
    var favorites: [GooglePlacesList] = []
    let locationManager = CLLocationManager()
    var httpClient: HTTPClient = HTTPClient()
    var googlePlacesList = Array<GooglePlacesList>()
    var currentLocationCordinates = CLLocationCoordinate2D()
    
    let categories = ["Default", "Airport", "Amusement Park", "Aquarium", "Art Gallery", "Bakery", "Bar", "Beauty Salon", "Bowling Alley",
                      "Bus Station", "Cafe", "Campground","Car Rental", "Casino", "Lodging", "Movie Theater", "Museum",
                      "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Subway Station", "Taxi Stand", "Train Station",
                      "Transit Station", "Travel Agency", "Zoo"]
    
    @IBOutlet weak var TFKeyword: UITextField!
    @IBOutlet weak var TFCategory: UITextField!
    @IBOutlet weak var TFDistance: UITextField!
    @IBOutlet weak var TFLocation: UITextField!
    @IBOutlet weak var favoriteTable: UITableView!
    
    @IBOutlet weak var tabSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registedForNotification()
        self.populateFavorites()
        self.setupUI()
        
        // steps to populate default values ( have to be removed )
        #if DEBUG
        self.TFKeyword.text = "USC"
        self.TFCategory.text = "Default"
        #endif
        
        self.getUserAutoLocation()
    }
    
    private func registedForNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(populateFavorites), name: NSNotification.Name(rawValue: "didModifyFavorites"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(tabSegmentedControl.selectedSegmentIndex == 1) {
            self.favoriteTable.reloadData()
        }
    }
    
    private func setupUI() {
       
        // set placeholders
        TFDistance.text = nil
        TFDistance.placeholder = "Enter distance (default 10 miles)"
        
        // prepare favorites table.
        self.favoriteTable.delegate = self
        self.favoriteTable.dataSource = self
        
        // Setting up the Location Text Field.
        self.TFLocation.text = "Your Location"
        self.TFLocation.delegate = self
        
        // Setting category picker
        self.TFCategory.text = "Default"
        PVCategory = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        PVCategory.delegate = self
        PVCategory.dataSource = self
        PVCategory.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        PVCategory.selectRow(0, inComponent:0, animated:true)
        TFCategory.inputView = PVCategory
        
        // Creating a ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        TFCategory.inputAccessoryView = toolBar
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
    
    private func getUserAutoLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
       
        self.currentLocationCordinates = (locationManager.location?.coordinate)!
        
        self.latitude = self.currentLocationCordinates.latitude
        self.longitude = self.currentLocationCordinates.longitude
    }
    
    @objc private func populateFavorites() {
        self.favorites.removeAll()
        for element in UserDefaults.standard.dictionaryRepresentation() {
            if element.key.range(of:"favorite_") != nil {
                var placeDict = element.value as! [String : String]
                
                if (placeDict["icon"] != nil), (placeDict["name"] != nil), (placeDict["place_id"] != nil), (placeDict["address"] != nil) {
                    let placeListObj = GooglePlacesList(icon: placeDict["icon"]!, name: placeDict["name"]!, placeId: placeDict["place_id"]!, vicinity: placeDict["address"]!)
                    self.favorites.append(placeListObj)
                }
            }
        }
    }
    
    @IBAction func favSegment(_ sender: UISegmentedControl) {
        homeSeg = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        self.toggleSelectedViewWithOption(sender.selectedSegmentIndex)
    }
    
    private func toggleSelectedViewWithOption(_ option: Int) {
        if(option == 0) {
            self.favoriteTable.isHidden = true
        }
        else {
            self.favoriteTable.isHidden = false
            self.favoriteTable.reloadData()
        }
    }
    
    @IBAction func searchPlaces(_ sender: UIButton) {
        
        if TFKeyword.text == "" {
            self.showToast(message: "Keyword cannot be empty")
            
            return
        }
        
        if (TFKeyword.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            self.showToast(message: "Keyword cannot be empty")
            
            return
        }
        
        var customLoc = ""
        var dist = TFDistance.text
        SwiftSpinner.show("Searching...")
        
        if (TFLocation.text! != "Your Location") {
            customLoc = TFLocation.text!
        }
        
        if TFDistance.text == "" {
            dist  = "10"
        }
        
        if (latitude != nil), (longitude != nil) {
            httpClient.fetchPlacesResult(outKeyword: TFKeyword.text!, outCateggory: TFCategory.text!, outLat: latitude, outLon: longitude, outDistance: dist!, outCustomLoc: customLoc) { [weak self] (result, error) in
                if(error == nil) {
                    self?.nextPageToken = result?.next_page_token
                    if let placesResults = result?.results {
                        self?.googlePlacesList = placesResults
                        self?.performSegue(withIdentifier: "placeListVC", sender: self)
                        SwiftSpinner.hide()
                    }
                }
                else {
                    print("Facing problem in fetching places list")
                }
            }
        }
    }
    
    @IBAction func clearPlaces(_ sender: UIButton) {
        TFKeyword.text = ""
        TFCategory.text = "Default"
        TFLocation.text = "Your Location"
        TFDistance.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PlacesListViewController {
            destination.placesList = self.googlePlacesList
            destination.nextPageToken = self.nextPageToken
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        self.present(acController, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TFCategory.text = categories[row]
    }
    
    @objc func doneClick() {
        TFCategory.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        TFCategory.text = "Default"
        TFCategory.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if self.favorites.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        
        } else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Favorites"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteTableViewCell
        
        if indexPath.row >= 0 {
            cell.setFavorite(favorites[indexPath.row])
        }
        
        return (cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        SwiftSpinner.show("Fetching place details...")
        if let selectedPlace = indexPath?.row {
            let placeId: String = favorites[selectedPlace].placeId
            let placeIconUrl = favorites[selectedPlace].icon
            httpClient.fetchPlaceDetails(outPlaceId: placeId) { [weak self] (result, error) in
                if(error == nil) {
                    if let placeDetails = result?.result {
                        guard let tabController = self?.storyboard?.instantiateViewController(withIdentifier: "placeDetailViewController") as? PlaceDetailTabViewController else { return }
                        tabController.didComeFromFavorites = true
                        
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
                    print("Facing problem in fetching user's current location")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let place = self.favorites[indexPath.row]
            Utils.deleteFavoriteWithPlaceId(place.placeId)
            self.favoriteTable.reloadData()
        }
        return [deleteAction]
    }
}

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.TFLocation.text = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
