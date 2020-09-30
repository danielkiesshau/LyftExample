//
//  Vehicle.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 29/09/20.
//

import MapKit

class VehicleAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    
}
