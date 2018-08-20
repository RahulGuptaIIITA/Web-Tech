//
//  PlaceDetailMapViewController.swift
//  travelen
//
//  Created by rahul gupta on 4/14/18.
//  Copyright © 2018 Kryptart. All rights reserved.
//


import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class PlaceDetailMapViewController: UIViewController, MKMapViewDelegate, GMSMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var route: [GoogleRoutes]?
    var httpClient = HTTPClient()
    var polyline = [MKPolyline]()
    var selectedTravelMode = "Driving"

    @IBOutlet weak var googleMap: GMSMapView!
    
    var placeDetail: GooglePlaceDetailsInfo?
    let locationManager = CLLocationManager()
    var sourceCordinates = CLLocationCoordinate2D()
    var desinationCordinates = CLLocationCoordinate2D()
    
 
    @IBOutlet weak var travelMap: MKMapView! {
        didSet {
            let noLocation = CLLocationCoordinate2D()
            let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500)
            self.travelMap.setRegion(viewRegion, animated: true)
        }
    }
    
    @IBOutlet weak var TFLocation: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {

        // autocomplete
        self.TFLocation.delegate = self
        self.forwardSourceGeocoding()
        
        // google map
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //Your map initiation code
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 15.0)
        
        self.googleMap.camera = camera
        self.googleMap.delegate = self
        self.googleMap?.isMyLocationEnabled = true
        self.googleMap.settings.myLocationButton = true
        self.googleMap.settings.compassButton = true
        self.googleMap.settings.zoomGestures = true
        

    }
    
    func createMarker(iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.icon = iconMarker
        marker.map = googleMap
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMap.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMap.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMap.isMyLocationEnabled = true
        googleMap.selectedMarker = nil
        return false
    }

    
    func forwardSourceGeocoding() {
        
        if (TFLocation.text! != "") {
            httpClient.fetchGeoCordinates(outAddress: TFLocation.text!) { [weak self] (result, error) in
                if(error == nil) {
                    if let geoCordinates = result?.results {
                        self?.sourceCordinates.latitude = geoCordinates[0].geometry.location.lat!
                        self?.sourceCordinates.longitude = geoCordinates[0].geometry.location.lng!
                        self?.forwardDestinationGeocoding()
                    }
                }
                else {
                    print("Facing problem in fetching Source Geo Cordinates")
                }
            }
        } else {
            self.sourceCordinates = (locationManager.location?.coordinate)!
            self.forwardDestinationGeocoding()
        }
    }
    
    func forwardDestinationGeocoding() {
        
        self.desinationCordinates.latitude = (self.placeDetail?.geometry?.location.lat)!
        self.desinationCordinates.longitude = (self.placeDetail?.geometry?.location.lng)!
        
        let sourcePlaceMark = MKPlacemark(coordinate: self.sourceCordinates)
        let destinationPlaceMark = MKPlacemark(coordinate: self.desinationCordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        
        var travelMode = ""
        if self.selectedTravelMode == "Walking" {
            travelMode = "walking"
            directionRequest.transportType = .walking
            
        } else if self.selectedTravelMode == "Driving" {
            travelMode = "driving"
            directionRequest.transportType = .automobile
            
        } else if self.selectedTravelMode == "Transit" {
            travelMode = "transit"
            directionRequest.transportType = .transit
            
        } else if self.selectedTravelMode == "Bicycling" {
            travelMode = "bicycling"
            directionRequest.transportType = .any
        }
        
        let slat = "\(self.sourceCordinates.latitude)"
        let slon = "\(self.sourceCordinates.longitude)"
        let sourceCordinatesString = slat + "," + slon
        
        let dlat = "\(self.desinationCordinates.latitude)"
        let dlon = "\(self.desinationCordinates.longitude)"
        let destinationCordinateString = dlat + "," + dlon
        
        httpClient.fetchRoute(outSource: sourceCordinatesString, outDestination: destinationCordinateString, outMode: travelMode) { [weak self] (result, error) in
            if(error == nil) {
                if let groute = result?.routes {
                    self?.route = groute
                    self?.googleMap.clear()
                    self?.createMarker(iconMarker: #imageLiteral(resourceName: "pin") , latitude: (self?.sourceCordinates.latitude)!, longitude: (self?.sourceCordinates.longitude)!)
                    self?.createMarker(iconMarker: #imageLiteral(resourceName: "pin") , latitude: (self?.desinationCordinates.latitude)!, longitude: (self?.desinationCordinates.longitude)!)
                    
                    let path = GMSPath.init(fromEncodedPath: (self?.route![0].overview_polyline.points)!)
                    
                    let polyline = GMSPolyline(path: path)
                    
                    polyline.strokeWidth = 4
                    polyline.strokeColor = UIColor.blue
                    polyline.map = self?.googleMap
                }
            }
        }
    }
    
    @IBAction func travelMode(_ sender: UISegmentedControl) {
        selectedTravelMode = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        self.setupUI()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        self.present(acController, animated: true, completion: nil)
    }
}

extension PlaceDetailMapViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.TFLocation.text = place.name
        self.forwardSourceGeocoding()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
