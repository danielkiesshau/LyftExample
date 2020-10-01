//
//  HomeViewController.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 29/09/20.
//

import UIKit
import CoreLocation
import MapKit

class HomeViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate {
  
    
    @IBOutlet weak var searchButton: UIButton!
    var recentLocations = [Location]()
    var locationManager: CLLocationManager!
    var currentUserLocation: Location!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locations = LocationService.shared.getRecentLocations()
        recentLocations = [locations[0], locations[1]]
        
        // Configure location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
       
        
        
        searchButton.layer.cornerRadius =  10.0
        // Add button drop shadow
        searchButton.layer.shadowRadius = 1
        searchButton.layer.shadowColor = UIColor.black.cgColor
        searchButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        searchButton.layer.shadowOpacity = 0.5
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationViewController = segue.destination as? LocationViewController {
            locationViewController.pickUpLocation = currentUserLocation
        } else if let routeViewController = segue.destination as? RouteViewController,
                  let dropOffLocation = sender as? Location{
            routeViewController.pickupLocation = currentUserLocation
            routeViewController.dropOffLocation = dropOffLocation 
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        
        let location = recentLocations[indexPath.row]
        cell.update(location: location)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dropOffLocation = recentLocations[indexPath.row]
        
        performSegue(withIdentifier: "RouteSegue", sender: dropOffLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let firstLocation = locations.first!
        currentUserLocation  = Location(title: "Current location", subtitle: "", lat: firstLocation.coordinate.latitude, lng: firstLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let distance = 500.0
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: true)
        loadVehicles(mapView: mapView, lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        // Create our custom annotation view with vehicle image
        let reuseIdentifier = "VehicleAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        } else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "car")
        annotationView?.transform = CGAffineTransform(rotationAngle: CGFloat(arc4random_uniform(360) * 180) / CGFloat.pi)
        return annotationView
    }
    
    func loadVehicles(mapView: MKMapView, lat: CLLocationDistance, lng: CLLocationDistance) {
        
        let offset = 0.00075
        
        let coord1 = CLLocationCoordinate2D(latitude: lat - offset, longitude: lng - offset)
        let coord2 = CLLocationCoordinate2D(latitude: lat,
                                            longitude: lng + offset)
        let coord3 = CLLocationCoordinate2D(latitude: lat,
                                            longitude: lng - offset)
        // add 3 vehicles annotations
        mapView.addAnnotations([
            VehicleAnnotation(coordinate: coord1),
            VehicleAnnotation(coordinate: coord2),
            VehicleAnnotation(coordinate: coord3)
        ])
    }
    
    
    
    
}
