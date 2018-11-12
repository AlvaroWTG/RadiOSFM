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

class LaunchViewController: UIViewController {

    // MARK: - Properties

    /** Property that represents the image view for the view */
    @IBOutlet weak var background: UIImageView!
    /** Property that represents the image view for the view */
    @IBOutlet weak var imageView: UIImageView!
    /** Property that represents whether an update is requested or not */
    private var updateRequested = false

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
}
