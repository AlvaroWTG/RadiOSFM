//
//  LaunchViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 12/11/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Toast
import Crashlytics

class LaunchViewController: UIViewController, NetworkDelegate {

    // MARK: - Properties

    /** Property that represents the image view for the view */
    @IBOutlet weak var imageView: UIImageView!
    /** Property that represents the label for the title */
    @IBOutlet weak var labelTitle: UILabel!
    /** Property that represents the label for the footer */
    @IBOutlet weak var labelFooter: UILabel!
    /** Property that represents whether an update is requested or not */
    private var updateRequested = false

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelFooter.text = NSLocalizedString("APP_COPYRIGHT", comment: Tag.Empty)
        self.labelTitle.text = NSLocalizedString("APP_NAME", comment: Tag.Empty)
        self.imageView.image = UIImage(named: "radio_app")

        // Initial backend request
        if NetworkUtils.shared.isOnline() {
            DispatchQueue.global(qos: .background).async {
                NetworkUtils.shared.delegate = self
                NetworkUtils.shared.post(0)
            }
        } else {
            let position = CSToastPositionCenter
            let duration = CSToastManager.defaultDuration()
            let message = NSLocalizedString("ALERT_NETWORK_DESC", comment: Tag.Empty)
            self.view.makeToast(message, duration: duration, position: position)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }

    // MARK: - Inherited functions from Network utils delegate

    func util(_ util: NetworkUtils, didReceiveResponse status: Int, data: Data, error: Error?) {
        if status == 200 { // success
            if let json = NetworkUtils.shared.deserialize(data) {
                if let countries = json["data"] as? [Any] {
                    LocalDatabase.standard.parseCountries(countries)
                }
            }
        } else { // error
            if let response = String(data: data, encoding: .utf8) {
                NSLog("[HTTP] Error! Received ERROR \(status)! Info: \(response)")
                Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: status, userInfo: [NSLocalizedDescriptionKey : response]))
            }
        }
        DispatchQueue.main.async { self.dismissLaunch() }
    }

    // MARK: - Function

    /**
     Function that fades in/out a view
     */
    @objc private func dismissLaunch() {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            NotificationCenter.default.post(name: .homeNotification, object: nil)
        }
    }
}
