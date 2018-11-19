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
    /** Property that represents the list of countries for the menu */
    private var countries = [String]()

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.topViewController?.navigationItem.title = NSLocalizedString("COUNTRY_TITLE", comment: Tag.Empty)

        // Setup table view controller and model
        self.countries = ["COUNTRY_0", "COUNTRY_1", "COUNTRY_2", "COUNTRY_3", "COUNTRY_4", "COUNTRY_5", "COUNTRY_6", "COUNTRY_7", "COUNTRY_8", "COUNTRY_9",
                          "COUNTRY_10", "COUNTRY_11", "COUNTRY_12", "COUNTRY_13", "COUNTRY_14", "COUNTRY_15", "COUNTRY_16", "COUNTRY_17", "COUNTRY_18", "COUNTRY_19",
                          "COUNTRY_20", "COUNTRY_21", "COUNTRY_22", "COUNTRY_23", "COUNTRY_24", "COUNTRY_25", "COUNTRY_26", "COUNTRY_27"]
        self.button.setTitle(NSLocalizedString("COUNTRY_BUTTON", comment: Tag.Empty).uppercased(), for: .normal)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Swap Back button
        NotificationCenter.default.post(name: .swapBackButton, object: nil)
    }

    // MARK: - Inherited functions from UITableView data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView = tableView
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationViewCell", for: indexPath) as? LocationViewCell {
            cell.labelTitle.text = NSLocalizedString(self.countries[indexPath.row], comment: Tag.Empty)
            cell.backgroundColor = .white
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countries.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // MARK: - Inherited functions from UITableView delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = NSLocalizedString(self.countries[indexPath.row], comment: Tag.Empty)
        tableView.deselectRow(at: indexPath, animated: true)
        NSLog("Log: user didSelectRowAt \(country)")
    }

    // MARK: - Inherited functions from Core location manager

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            manager.stopUpdatingLocation()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placemark = placemarks?.last { // get country code
                    NSLog("[CLGeocoder] Log: Placemark country code: \(placemark.isoCountryCode ?? "unknown")")
                } else if error != nil { // error reversing geocode
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

    // MARK: - IBAction function implementation

    /**
     Function that performs an action when the menu button is clicked
     - parameter sender: The identifier of the sender of the action
     */
    @IBAction func didPress(_ sender: UIButton) {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - Functions

    /**
     Function that removes the present view controller
     - parameter sender: The button sender of the action
     */
    @objc private func didPressBack(_ sender: UIButton?) {
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .swapBackButton, object: nil)
    }

    /**
     Function that pushes a permission denied alert
     */
    @objc private func pushAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("ALERT_LOCATION_TITLE", comment: Tag.Empty), message: NSLocalizedString("ALERT_PERMISSION_DESC", comment: Tag.Empty), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ALERT_PERMISSION_CLOSE", comment: Tag.Empty), style: .default, handler: { (action) in
            exit(0)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ALERT_PERMISSION_BUTTON", comment: Tag.Empty), style: .cancel, handler: { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) { _ = NetworkUtils.shared.open(url) }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}
