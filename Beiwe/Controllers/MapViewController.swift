//
//  Map.swift
//  Beiwe
//
//  Created by Zexing on 6/25/18.
//  Copyright © 2018 Rocketfarm Studios. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import UIKit

//initially the map will zoom into user location. if the button is clicked, then zoom into search location
var searchButtonClicked = false

class MapViewController: UIViewController,UISearchBarDelegate,CLLocationManagerDelegate {

    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    //
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //goButton
        goButton.isHidden = false
        
        
        //ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start{ (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            if response == nil{
                print("error")
                
            }
            else{
                
                //getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //creating annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                //zoom in the map
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegionMake(coordinate, span)
                
                self.mapView.setRegion(region, animated: true)
                self.mapView.showsUserLocation = true
                
                //initially the map will zoom into user location. if the button is clicked, then zoom into search location
                searchButtonClicked = true
            
            }
        }
    }
    
    //show self location
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location  = locations[0]
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let userLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        self.mapView.showsUserLocation = true
        //buttonClick initially is false, means this if statement (set initial region) only run once.
        if searchButtonClicked == false{
            let region : MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
            mapView.setRegion(region, animated: true)
            //goButton.isHidden = false
        }
    }
        
    
    
            
            
    
    
    override func viewDidLoad () {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        goButton.isHidden = true

      
    }
    
    
    
}
