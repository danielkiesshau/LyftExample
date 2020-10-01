//
//  RouteViewController.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 30/09/20.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var routeLabelView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selecteRideButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblPickup: UILabel!
    @IBOutlet weak var lblDropoff: UILabel!
    
    var pickupLocation: Location!
    var dropOffLocation: Location!
    var rideQuotes = [RideQuote]()
    var selectedIndex = 0
    
    override func viewDidLoad() {
        
//      Rounding borders
        routeLabelView.layer.cornerRadius = 10.0
        backButton.layer.cornerRadius = backButton.frame.size.width / 2.0
        selecteRideButton.layer.cornerRadius = 10.0
        
        rideQuotes = RideQuoteService.shared.getQuotes(pickupLocation: pickupLocation!, dropffLocation: dropOffLocation!)
        
        // adding annotations
        
        let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupLocation!.lat, longitude: pickupLocation!.lng)
        let dropOffCoordinate = CLLocationCoordinate2D(latitude: dropOffLocation!.lat, longitude: dropOffLocation!.lng)
        let pickupAnnotation = LocationAnnotion(coordinate: pickupCoordinate, locationType: "pickup")
        let dropOffAnnotation = LocationAnnotion(coordinate: dropOffCoordinate, locationType: "dropoff")
        
        mapView.addAnnotations([pickupAnnotation,dropOffAnnotation])
        mapView.delegate = self
        
        lblPickup.text = pickupLocation?.title
        lblDropoff.text = dropOffLocation?.title
        
        displayRoute(sourceLocation: pickupLocation!, destinationLocation: dropOffLocation!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideQuotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideQuoteCell") as! RideQuoteCell
        
        let rideQuote = rideQuotes[indexPath.row]
        cell.update(rideQuote: rideQuote)
        cell.updateStatus(status: indexPath.row == selectedIndex)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let selectedRideQuote = rideQuotes[selectedIndex]
        
        selecteRideButton.setTitle("Select \(selectedRideQuote.name)", for: .normal)
        tableView.reloadData()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reusableIdentifier = "LocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableIdentifier)
         
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reusableIdentifier)
        } else {
            annotationView!.annotation = annotation
        }
        let locationAnnotation = annotation as! LocationAnnotion
        annotationView!.image = UIImage(named: "dot-\(locationAnnotation.locationType)")
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
            
                let EDGE_INSET: CGFloat = 80.0
                let boundingMapRect = route.polyline.boundingMapRect
                self.mapView.setVisibleMapRect(boundingMapRect, edgePadding: UIEdgeInsets(top: EDGE_INSET, left: EDGE_INSET, bottom: EDGE_INSET, right: EDGE_INSET), animated: false)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5.0
        renderer.strokeColor = UIColor(red: 247.0/255.0, green: 66.0/255.0, blue: 190.0/255.0, alpha: 1)
        return renderer
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let driverViewController = segue.destination as? DriverViewController {
            driverViewController.pickUpLocation = pickupLocation
            driverViewController.dropOffLocation = dropOffLocation
        }
    }
    
}
