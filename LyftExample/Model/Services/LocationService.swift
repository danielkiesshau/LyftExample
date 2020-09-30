//
//  LocationService.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 29/09/20.
//

import Foundation

class LocationService {
    static let shared = LocationService()
    
    private var recentLocations = [Location]()
    
    private init() {
        // configure to get locations.json
        let locationUrl = Bundle.main.url(forResource: "locations", withExtension: "json")!
        
        // convert it contents to JSON
        let data = try! Data(contentsOf: locationUrl)
        let decoder = JSONDecoder()
        recentLocations = try! decoder.decode([Location].self, from: data)
        
    }
    
    func getRecentLocations() -> [Location] {
        return recentLocations
    }
}
