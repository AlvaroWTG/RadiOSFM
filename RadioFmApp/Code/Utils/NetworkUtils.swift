//
//  NetworkUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 12/11/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics
import Reachability
import CoreTelephony
import SystemConfiguration.CaptiveNetwork

protocol NetworkDelegate: class {
    
    /**
     This method is invoked when the util receives a response.
     - parameter util: The util instance that handles communication
     - parameter error: The error value of the response
     - parameter message: The string value of the message
     */
    func util(_ util: NetworkUtils, didReceiveResponse status: Int, error: Error?, message: String?)
}

class NetworkUtils: NSObject {

    // MARK: - Properties

    /** Property that represents the delegate of this util class */
    weak var delegate: NetworkDelegate?
    /** Property that represents the reachability of the device */
    var reachability: Reachability = Reachability()!
    /** Property that represents whether the reachability is live or not */
    var isLive: Bool = false

    // MARK: - Singleton

    static let shared = NetworkUtils()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Functions
}
