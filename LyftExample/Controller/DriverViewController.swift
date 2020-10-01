//
//  DriverViewController.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 30/09/20.
//

import Foundation
import UIKit
import MapKit

class DriverViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var licensePlate: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var pickUpLocation: Location?
    var dropOffLocation: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        driverImageView.layer.cornerRadius = driverImageView.frame.size.width / 2.0
        licensePlate.layer.cornerRadius = 15.0
        licensePlate.layer.borderColor = UIColor.gray.cgColor
        licensePlate.layer.borderWidth = 1.0
        
        
        backButton.layer.cornerRadius = backButton.frame.size.width / 2.0
        
        
        let (driver, eta) = DriverService.shared.getDriver(pickupLocation: pickUpLocation!)
        
        etaLabel.text = "ARRIVES IN \(eta) MIN"
        driverName.text = driver.name
        carName.text = driver.car
        
        let ratingValue =  String(format: "%.1f", driver.rating);
        ratingImageView.image = UIImage(named: "rating-\(ratingValue)")
        ratingLabel.text = ratingValue
        
        carImageView.image = UIImage(named: driver.car)
        driverImageView.image = UIImage(named: driver.thumbnail)
        licensePlate.text = driver.licenseNumber
        
        let pickUpCoordinate = CLLocationCoordinate2D(latitude: pickUpLocation!.lat, longitude: pickUpLocation!.lng)
        let dropOffCoordinate = CLLocationCoordinate2D(latitude: dropOffLocation!.lat, longitude: dropOffLocation!.lng)
        
        let driverAnnotation = VehicleAnnotation(coordinate: driver.coordinate)
        
        let pickUpAnnotation = LocationAnnotion(coordinate: pickUpCoordinate, locationType: "pickup")
        let dropOffAnnotation = LocationAnnotion(coordinate: dropOffCoordinate, locationType: "dropoff")
        let annotations: [MKAnnotation] = [pickUpAnnotation, dropOffAnnotation,  driverAnnotation]
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)

        
        let driverLocation = Location(title: driver.name, subtitle: driver.licenseNumber, lat: driver.coordinate.latitude, lng: driver.coordinate.longitude)
        displayRoute(sourceLocation: driverLocation, destinationLocation: pickUpLocation!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIndentifier = annotation is VehicleAnnotation ? "VehicleAnnotation" : "LocationAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIndentifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        if annotation is VehicleAnnotation {
            annotationView?.image = UIImage(named: "car")
        } else if let locationAnnotation = annotation as? LocationAnnotion {
            annotationView?.image = UIImage(named: "dot-\(locationAnnotation.locationType)")
            
        }
        
        return annotationView
    }
    
    
    func displayRoute(sourceLocation: Location, destinationLocation: Location){
        let sourceCoordinate = CLLocationCoordinate2D(latitude: sourceLocation.lat, longitude: sourceLocation.lng)
        let destinationCoordinate =  CLLocationCoordinate2D(latitude: destinationLocation.lat, longitude: destinationLocation.lng)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if let error = error{
                print("There's an error with calculating route \(error)")
                return
            }
            
            if let response = response {
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5.0
        renderer.strokeColor = UIColor(red: 247.0/255.0, green: 66.0/255.0, blue: 190.0/255.0, alpha: 1)
        return renderer
    }
    
    @IBAction func backBtnDidTapped(_ sender: UIButton) {
        print("tapped")
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
