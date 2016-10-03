//
//  ViewController.swift
//  WakeUp
//
//  Created by Mark Murtagh on 25/05/2016.
//  Copyright © 2016 MAVM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
  //  let alert : NSAlert? = NSAlert()
    var selectedPin : MKPlacemark? = nil
    //var placemark2 : CLLocation? = nil
    var location2 : CLLocation? = nil
    var resultSearchController:UISearchController? = nil
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate=self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization() // this will fuck up app when its in the background, dont forget
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true  // blue dot
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        let location = locations.last
        let centre = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude) // actual longitude x latitude
        let region = MKCoordinateRegion(center: centre, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)) // how zoomed in itll go
        self.mapView.setRegion(region, animated: true) // zoom animation
        self.locationManager.stopUpdatingLocation()
        location2 = location // blue dot, users current location
        print("Location")
        print(location?.coordinate)
        location2=location
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
        print("Errors" + error.localizedDescription)
    }
    

    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}



extension ViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark // red pin
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05) // RADIIUSSSSSSSSSSSS
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        print(placemark.coordinate)
        
        //make CLLocation out of placemark
        let locationPlacemark = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        
        
        let distanceInMeters = location2?.distance(from: locationPlacemark)
        print(distanceInMeters)
        
        
    }
}



extension ViewController {
    @objc(mapView:viewForAnnotation:) func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}
















