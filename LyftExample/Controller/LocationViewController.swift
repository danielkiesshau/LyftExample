//
//  LocationViewController.swift
//  LyftExample
//
//  Created by Daniel Kiesshau on 30/09/20.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MKLocalSearchCompleterDelegate {
    var locations = [Location]()
    var pickUpLocation: Location?
    var dropOffLocation: Location?
    var searchCompleter = MKLocalSearchCompleter()
    var searchResult = [MKLocalSearchCompletion]()

    @IBOutlet weak var dropOffTexField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelDidTaped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropOffTexField.becomeFirstResponder()
        dropOffTexField.delegate = self
        locations = LocationService.shared.getRecentLocations()
        searchCompleter.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.isEmpty ?  locations.count : searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        
        if searchResult.isEmpty{
            let location = locations[indexPath.row]
            cell.update(location: location)
        } else {
            let result = searchResult[indexPath.row]
            cell.update(searchResult: result)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dropOffLocation = locations[indexPath.row]
        
        performSegue(withIdentifier: "RouteSegue", sender: dropOffLocation)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let latestString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if latestString.count > 3 {
            searchCompleter.queryFragment = latestString
        }
        return true
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResult = completer.results
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let routeViewController = segue.destination as? RouteViewController, let dropOffLocation = sender as? Location {
            routeViewController.dropOffLocation = dropOffLocation
            routeViewController.pickupLocation = pickUpLocation
        }
    }
     
}
