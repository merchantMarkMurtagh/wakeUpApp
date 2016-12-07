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
import AVFoundation


protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var selectDButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    
  //  let alert : NSAlert? = NSAlert()
    var selectedPin : MKPlacemark? = nil
    var printPin : MKPlacemark? = nil
    //var placemark2 : CLLocation? = nil
    var location2 : CLLocation? = nil
    var resultSearchController:UISearchController? = nil
    let locationManager = CLLocationManager()
    var locationPlacemark :CLLocation? = nil
    var selectedDestination :CLLocation? = nil
    var radiuz = 0.0
    var locationPicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.isHidden=true
        
        if(locationPicked==false)
        {
            cancelButton.isHidden=true
            mapView.removeAnnotations(mapView.annotations)
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
            //print(radiuz)
            print(locationPicked)
        
        
        }
        
        
        
        if(locationPicked==true)
        {
            //cancelButton.isHidden=false
            self.locationManager.delegate=self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization() // this will fuck up app when its in the background, dont forget
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true  // blue dot
            selectDButton.isHidden=true
            dropPinZoomInTwo(printPin!)
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let span = MKCoordinateSpanMake(0.05, 0.05) // RADIIUSSSSSSSSSSSS
            let region = MKCoordinateRegionMake((printPin?.coordinate)!, span)
            mapView.setRegion(region, animated: true)
            
            //make CLLocation out of placemark
            
            locationPlacemark = CLLocation(latitude: (printPin?.coordinate.latitude)!, longitude: (printPin?.coordinate.longitude)!) // red pin
            
            let distanceInMeters = locationManager.location?.distance(from: locationPlacemark!)   // how far away blue dot from pin is.
            
            if(distanceInMeters!<(radiuz*1000))
            {
                // create a sound ID, in this case its the tweet sound.
                let systemSoundID: SystemSoundID = 1322
                let alertController = UIAlertController(title: "iOScreator", message:
                    "YOUR NEAR YOUR STOP!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                // to play sound
                AudioServicesPlaySystemSound (systemSoundID)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        
        }
    }
    
    @IBAction func cancelSelection(_ sender: UIButton) {
        
        locationPicked=false
        printPin=nil
        selectedPin=nil
        selectDButton.isHidden=false
        
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        if(locationPicked==false)
        {
            let location = locations.last
            let centre = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude) // actual longitude x latitude
            let region = MKCoordinateRegion(center: centre, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)) // how zoomed in itll go
            self.mapView.setRegion(region, animated: true) // zoom animation
            self.locationManager.stopUpdatingLocation() ///???
            location2 = location // blue dot, users current location
            
            location2=location
        }
        
        
    }
    
    @IBAction func selectButtonClicked(_ sender: UIButton) {
        
        if (locationPlacemark != nil)
        {
            
            selectedDestination=locationPlacemark
            printPin=selectedPin
            performSegue(withIdentifier: "pickRadius", sender: radiuz)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {//
        
        if(segue.identifier=="pickRadius")
        {
            let radVC:DistanceViewController=segue.destination as! DistanceViewController
            let data = selectedPin
            radVC.selected=data
        }
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
    
    func dropPinZoomInTwo(_ placemark:MKPlacemark) {
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
        let span = MKCoordinateSpanMake(0.005, 0.005) // RADIIUSSSSSSSSSSSS
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
                print(placemark.coordinate)
        
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
       
        locationPlacemark = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude) // red pin
        let distanceInMeters = location2?.distance(from: locationPlacemark!)   // how far away blue dot from pin is.
        let dif = distanceInMeters
       
    }
        
    
    
}
















