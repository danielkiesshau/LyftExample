//
//  LocationAnnottion.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 30/09/20.
//

import Foundation
import MapKit

class LocationAnnotion: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let locationType: String
    
    init(coordinate: CLLocationCoordinate2D, locationType: String) {
        self.coordinate = coordinate
        self.locationType = locationType
    }
    
}
