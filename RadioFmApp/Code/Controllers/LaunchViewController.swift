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
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissLaunch), userInfo: nil, repeats: false)
//            DispatchQueue.global(qos: .background).async {
//                NetworkUtils.shared.delegate = self
//                NetworkUtils.shared.post(0)
//            }
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

    func util(_ util: NetworkUtils, didReceiveResponse status: Int, error: Error?, message: String?) {
//        let response = message ?? Tag.Unknown
//        if status == 200 { // success
//            NSLog("[HTTP] Log: \(status) - Available version: \(response)")
//            if let parameters = OSUtils.shared.getProjectParameters() {
//                let projectVersion = ParserUtils.shared.substring(parameters[0], key: Tag.Dot, isPrefix: true)
//                if response > projectVersion { // update available
//                    UserDefaults.standard.set(true, forKey: "updateAvailable")
//                    DispatchQueue.main.async { self.toggleDialog(true, response: response) }
//                } else { // same version
//                    UserDefaults.standard.set(false, forKey: "updateAvailable")
//                    NSLog("[HTTP] Log: No update available...")
//                }
//            }
//        } else {
//            UserDefaults.standard.set(false, forKey: "updateAvailable")
//            NSLog("[HTTP] Error! Received ERROR \(status)! Info: \(response)")
//            let userInfo = [NSLocalizedDescriptionKey : "Versionscheck request failed",
//                            NSLocalizedFailureReasonErrorKey : "Response returned \(status) - \(response)",
//                NSLocalizedRecoverySuggestionErrorKey : "Is the server up and running?"]
//            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
//        }
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
