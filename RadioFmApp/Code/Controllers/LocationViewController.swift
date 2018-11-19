//
//  LocationViewController.swift
//  RadioFmApp
//
//  Created by WebToGo on 11/13/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Crashlytics
import CoreLocation

class LocationViewCell: UITableViewCell {

    // MARK: - Properties

    /** Property that represents the label for the cell */
    @IBOutlet weak var labelTitle: UILabel!
}

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    // MARK: - Properties

    /** Property that represents the table view for the screen */
    @IBOutlet weak var tableView: UITableView!
    /** Property that represents the button for the screen */
    @IBOutlet weak var button: UIButton!
    /** Property that represents the location manager of the device */
    private var manager = CLLocationManager()

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Inherited functions from Core location manager

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            manager.stopUpdatingLocation()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placemark = placemarks?.last {
                    NSLog("[CLGeocoder] Log: Placemark country code: \(placemark.isoCountryCode ?? "unknown")")
                } else if error != nil {
                    NSLog("Error! An error occurred with reverse geodecode location! Error 405 - \(error!.localizedDescription)")
                    let userInfo = [NSLocalizedDescriptionKey : "CLLocationManager - Failed to greverse geocode location",
                                    NSLocalizedFailureReasonErrorKey : "405 - \(error!.localizedDescription)"]
                    Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
                } else { // placemark not found
                    NSLog("Error! An error occurred with reverse geodecode location! Error 406 - Last placemark not found")
                    let userInfo = [NSLocalizedDescriptionKey : "CLLocationManager - Failed to get last placemark",
                                    NSLocalizedFailureReasonErrorKey : "406 - Last placemark not found"]
                    Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
                }
            })
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        NSLog("Error! Location didFailWithError! Error 404 - \(error.localizedDescription)")
        let userInfo = [NSLocalizedDescriptionKey : "CLLocationManager - Location didFailWithError",
                        NSLocalizedFailureReasonErrorKey : "404 - \(error.localizedDescription)"]
        Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                if Verbose.Active { NSLog("[CoreLocation] Log: Location access isn't determined...") }
                manager.requestWhenInUseAuthorization()
                break
            case .authorizedWhenInUse:
                if Verbose.Active { NSLog("[CoreLocation] Log: Location access is authorized when in use...") }
                manager.startUpdatingLocation()
                break
            case .authorizedAlways:
                if Verbose.Active { NSLog("[CoreLocation] Log: Location access is always authorized...") }
                manager.startUpdatingLocation()
                break
            case .restricted:
                if Verbose.Active { NSLog("[CoreLocation] Error! Location access is restricted!") }
                self.performSelector(onMainThread: #selector(self.pushAlert), with: nil, waitUntilDone: false)
                break
            case .denied:
                if Verbose.Active { NSLog("[CoreLocation] Error! Location access is denied!") }
                self.performSelector(onMainThread: #selector(self.pushAlert), with: nil, waitUntilDone: false)
                break
        }
    }

}
