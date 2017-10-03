//
//  ViewController.swift
//  SnatchDeveloperTest
//
//  Created by Shehab Saqib on 30/08/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices

class LocationsTableViewController: UITableViewController, SFSafariViewControllerDelegate{
    
    var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    var searchData = [WikiAPI]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    // MARK: - Core Location

extension LocationsTableViewController: CLLocationManagerDelegate {
    
    func startLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 20
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if startLocation == nil {
            startLocation = locations.first
        } else {
            guard let latest = locations.first else { return }
            
            let distanceInMeters = startLocation?.distance(from: latest)
            let coordinates = manager.location?.coordinate
            let lat = coordinates!.latitude
            let lon = coordinates!.longitude
            
            WikiAPI.performSearch(lat: lat, lon: lon) { (results:[WikiAPI]?) in
                if let geosearchData = results {
                    self.searchData = geosearchData
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            print("Distance in meters: \(distanceInMeters!)")
            print("lat = \(lat) &&&& long = \(lon)")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
        
        if status == .denied || status == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
    }
}

    // MARK: - SafariView Delegate

    extension LocationsTableViewController {
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
}

    // MARK: - Table view data source
    
    extension LocationsTableViewController {
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchData.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            let searchObject = searchData[indexPath.row]
            
            cell.textLabel?.text = searchObject.title
            cell.detailTextLabel?.text = "\(Double(searchObject.distance)) Metres"

            return cell            
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let searchObject = searchData[indexPath.row]
            let placeName = searchObject.title
            
            let url = WikiAPI.wikiURL(name: placeName)
            
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            self.present(safariVC, animated: true, completion: nil)
            safariVC.delegate = self
        }
        
    }
    
    


