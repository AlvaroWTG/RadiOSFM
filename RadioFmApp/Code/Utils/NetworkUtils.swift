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
import CoreTelephony
import Reachability
import SystemConfiguration.CaptiveNetwork

protocol NetworkDelegate: class {

    /**
     This method is invoked when the util receives a response.
     - parameter util: The util instance that handles communication
     - parameter message: The string value of the message
     - parameter error: The error value of the response
     */
    func util(_ util: NetworkUtils, didReceiveResponse status: Int, data: Data, error: Error?)
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

    /**
     Function that obtains the IP address for a type
     - parameter type: The type of IP address
     - returns: The IP address found
     */
    func getIpAddressFor(_ type: String) -> String? {
        var wifiAddress: String?
        var cellularAddress: String?
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) { // Check for IPv4 or IPv6 interface:
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if  name == "en0" { // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    wifiAddress = String(cString: hostname)
                    if Verbose.Active { NSLog("Log: IP Adress - \(name) on \(wifiAddress ?? "0.0.0.0")...") }
                } else if name == "pdp_ip0" { // cellular address
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    cellularAddress = String(cString: hostname)
                    if Verbose.Active { NSLog("Log: IP Adress - \(name) on \(cellularAddress ?? "0.0.0.0")...") }
                }
            }
        }
        freeifaddrs(ifaddr)
        if type == "wifi" { // wifi
            return wifiAddress ?? "0.0.0.0"
        } else { return cellularAddress ?? "0.0.0.0" } // cellular
    }

    /**
     Function that obtains the IMSI of the device
     - returns: The device IMSI code
     */
    func getIMSI() -> String {
        let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        let mcc = carrier?.mobileCountryCode ?? "000"
        let mnc = carrier?.mobileNetworkCode ?? "000"
        return "\(mcc)\(mnc)"
    }

    /**
     Function that obtains the carrier ISO country code
     - returns: The ISO country code of the SIM
     */
    func getIsoCountryCode() -> String {
        if !self.isSimSupported() { return Tag.Unknown }
        let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        return carrier?.isoCountryCode ?? Tag.Unknown
    }

    /**
     Function that obtains the network operator
     - returns: The result network operator
     */
    func getNetworkOperator() -> String {
        return CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? Tag.Unknown
    }

    /**
     Function that obtains the network type
     - parameter fromStatusBar: Whether we read from status bar or not
     - returns: The network type found
     */
    func getNetworkType() -> String {
        let networkType = self.readNetworkType()
        switch networkType {
            case 0: return NSLocalizedString("TEST_NETWORK_TYPE_UNKNOWN", comment: Tag.Empty)
            case 1: return NSLocalizedString("TEST_NETWORK_TYPE_2G", comment: Tag.Empty)
            case 2: return NSLocalizedString("TEST_NETWORK_TYPE_3G", comment: Tag.Empty)
            case 3: return NSLocalizedString("TEST_NETWORK_TYPE_4G", comment: Tag.Empty)
            case 4: return NSLocalizedString("TEST_NETWORK_TYPE_LTE", comment: Tag.Empty)
            case 5: return NSLocalizedString("TEST_NETWORK_TYPE_WIFI", comment: Tag.Empty)
            default: return NSLocalizedString("TEST_NETWORK_TYPE_UNKNOWN", comment: Tag.Empty)
        }
    }

    /**
     Function that obtains the phone number of the device
     - returns: The phone number
     */
    func getPhoneNumber() -> String {
        if let phoneNumber = UserDefaults.standard.string(forKey: "SBFormattedPhoneNumber") { return phoneNumber }
        return Tag.Unknown
    }

    /**
     Function that obtains the signal strength
     - returns: The signal strength result
     */
    func getSignalStrength() -> Int {
        let strengthBars = self.readStatusBar("UIStatusBarSignalStrengthItemView", key: "signalStrengthBars")
        if Verbose.Active { NSLog("Log: Mobile signal strength - \(strengthBars) strength bars") }
        return strengthBars
    }

    /**
     Function that obtains the WiFi BSSID that you are currently connected
     - returns: The BSSID result that the device is currently connected
     */
    func getWifiBssid() -> String {
        var bssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let networkInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    bssid = networkInfo[kCNNetworkInfoKeyBSSID as String] as? String
                    break
                }
            }
        }
        return bssid?.uppercased() ?? Tag.Unknown
    }

    /**
     Function that obtains the WiFi SSID that you are currently connected
     - returns: The SSID result that the device is currently connected
     */
    func getWifiSsid() -> String {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let networkInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid?.uppercased() ?? Tag.Unknown
    }

    /**
     Function that checks if the airplane mode is on or not
     - returns: Represents true if there is Mobile data enabled and false is not
     */
    func isAirplaneModeEnabled() -> Bool {
        if self.isOnline() { return false }
        let networkType = self.getNetworkType()
        return networkType == Tag.Unknown
    }

    /**
     Function that checks whether the device is online or not
     - returns: The boolean result whether the device is somehow online or not
     */
    func isOnline() -> Bool {
        if !self.isLive { self.setupReachability() }
        return self.reachability.connection != .none
    }

    /**
     Function that checks if the Mobile network is connected or not
     - returns: Represents true if there is Mobile network connected and false is not
     */
    func isReachableViaWAN() -> Bool {
        if !self.isLive { self.setupReachability() }
        return self.reachability.connection == .cellular
    }

    /**
     Function that checks if the Wifi is connected or not
     - returns: Represents true if there is Wifi connected and false is not
     */
    func isReachableViaWiFi() -> Bool {
        if !self.isLive { self.setupReachability() }
        return self.reachability.connection == .wifi
    }

    /**
     Function that checks if the device is roaming or not
     - returns: True if it is roaming and false if not
     */
    func isRoaming() -> Bool {
        if !self.isOnline() { return false }
        let simCountryCode = self.getIsoCountryCode()
        if let deviceCountryCode = UserDefaults.standard.string(forKey: "sIsoCountryCode") {
            if deviceCountryCode.uppercased() == simCountryCode { return false }
            if Verbose.Active { NSLog("Log: \(deviceCountryCode) is different from \(simCountryCode), so check reachability...") }
            return self.isReachableViaWAN()
        } else { // error
            NSLog("Error! DEVICE country code 'unknown' or SIM country code '\(simCountryCode)' couldn't be read.")
            return false
        }
    }

    /**
     Function that checks if the SIM card is supported
     - returns: Whether SIM is supported or not
     */
    func isSimSupported() -> Bool {
        let networkOperator = self.getNetworkOperator()
        let supportedSIM = networkOperator != Tag.Unknown
        if Verbose.Active { NSLog(supportedSIM ? "Log: SIM is ready!" : "Error! There is no SIM, please check it") }
        return supportedSIM
    }

    /**
     Function that opens an URL on the app
     - parameter url: A URL (Universal Resource Locator)
     - returns: Wheter the resource located by the URL was successfully opened
     */
    func open(_ url: URL) -> Bool {
        var result = false
        if !UIApplication.shared.canOpenURL(url) { return result }
        UIApplication.shared.open(url, options: [:]) { (success) in
            if Verbose.Active {
                let messageError = "[UIApplication] Error! An unknown error when trying to open URL '\(url.absoluteString)'"
                NSLog(success ? "[UIApplication] Log: URL '\(url.absoluteString)' opened successfully" : messageError)
                if !success { // failed to open
                    let userInfo = [NSLocalizedDescriptionKey : "unknown error trying to open URL"]
                    Crashlytics.sharedInstance().recordError(NSError(domain: "UIApplication", code: 502, userInfo: userInfo))
                }
            }
            result = success
        }
        return result
    }

    /**
     Function that post a request with a body
     - parameter level: The level of request
     - parameter input: The input of request
     */
    func post(_ level: Int, input: String) {
        if NetworkUtils.shared.isOnline() {
            if let url = URL(string: self.getRequestAt(level, input: input)) {
                let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                    if let httpResponse = response as? HTTPURLResponse {
                        if let data = data { // valid data
                            UserDefaults.standard.set(data, forKey: "responseJsonData")
                            self.delegate?.util(self, didReceiveResponse: httpResponse.statusCode, data: data, error: error)
                        } else if let error = error { // error
                            if let errorData = error.localizedDescription.data(using: .utf8) {
                                self.delegate?.util(self, didReceiveResponse: httpResponse.statusCode, data: errorData, error: error)
                            }
                        } else { // unknown error
                            if let errorData = "No data found in response".data(using: .utf8) {
                                self.delegate?.util(self, didReceiveResponse: httpResponse.statusCode, data: errorData, error: nil)
                            }
                        }
                    } else { // timeout
                        if let errorData = "Request timeout".data(using: .utf8) {
                            self.delegate?.util(self, didReceiveResponse: 408, data: errorData, error: error)
                        }
                    }
                }
                task.resume()
            }
        } else { // offline
            if let errorData = "No internet connection".data(using: .utf8) {
                self.delegate?.util(self, didReceiveResponse: 523, data: errorData, error: nil)
            }
        }
    }

    /**
     Function that read the network type from status bar
     - returns: The resulting network type
     */
    func readNetworkType() -> Int {
        return self.readStatusBar("UIStatusBarDataNetworkItemView", key: "dataNetworkType")
    }

    // MARK: - Inherited function from Reachability

    /**
     Function that deals with changes on reachability
     - parameter notification: The notification object received
     */
    @objc func reachabilityDidChange(_ notification: Notification) {
        if notification.name == .reachabilityDidChange {
            if let reachability = notification.object as? Reachability {
                switch reachability.connection {
                case .none:
                    NSLog("**** Network Not Reachable ****")
                    break
                case .wifi:
                    print("**** Reachable via WiFi ****")
                    break
                case .cellular:
                    print("**** Reachable via Cellular ****")
                    break
                }
            }
        }
    }

    // MARK: - Auxiliary functions

    /**
     Function that gets the request session
     - parameter level: The level of request
     - returns: The request session created
     */
    private func getRequestAt(_ level: Int, input: String) -> String {
        let origin = Api.RadioOriginTest
        var stringBuilder = Tag.Empty
        switch level {
            case 0: // GET Countries
                stringBuilder = "\(origin)/countries"
                break
            case 1: // GET Country - Stations
                stringBuilder = "\(origin)/countries/\(input)/stations"
                break
            case 2: // GET Country - Counters
                stringBuilder = "\(origin)/countries/\(input)/counters"
                break
            case 3: // GET Country - Locations
                stringBuilder = "\(origin)/countries/\(input)/locations"
                break
            default: // error
                NSLog("[HTTP] Error! Invalid request level!")
                break
        }
        if Verbose.Active { NSLog("[HTTP] Log: Sending GET request \(stringBuilder)") }
        return stringBuilder
    }

    /**
     Function that reads the status bar
     - parameter keySubview: The subview key to look for
     - parameter key: The item key to look for
     - returns: The nsnumber result
     */
    private func readStatusBar(_ keySubview: String, key: String) -> Int {
        var statusBarItem: UIView?
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            NSLog("[Network] Error! Invalid raw value for statusBarWindow.statusBar!")
            let userInfo = [NSLocalizedDescriptionKey : "Invalid raw value for statusBarWindow.statusBar"]
            Crashlytics.sharedInstance().recordError(NSError(domain: "UIApplication", code: 501, userInfo: userInfo))
            return 0
        }
        if NSClassFromString("UIStatusBar_Modern") == nil { return 0 }
        if statusBar.isKind(of: NSClassFromString("UIStatusBar_Modern")!) {
            if let modernBar = statusBar.value(forKey: "statusBar") as? UIView {
                if let foregroundView = modernBar.value(forKey: "foregroundView") as? UIView {
                    for subview in foregroundView.subviews {
                        if subview.isKind(of: NSClassFromString(keySubview)!) {
                            statusBarItem = subview
                            break
                        }
                    }
                }
            }
        }
        if let value = statusBarItem?.value(forKey: key) as? Int { return value }
        NSLog("[Network] Error! Invalid statusBarItem obtained!")
        return 0
    }

    /**
     Function that evaluates reachability and start the notifier
     */
    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: .reachabilityDidChange, object: reachability)
        do { // setup reachability
            self.reachability = Reachability()!
            try self.reachability.startNotifier()
            self.isLive = true
        }catch { NSLog("[Reachability] Error 404 - Could not start reachability notifier!") }
    }

    // MARK: -  JSON de-/serialization functions

    /**
     Function that obtain a json from the serialized one
     - parameter serializedJson: The JSON object serialized
     - returns: The json object obtained from the body
     */
    func deserialize(_ serializedJson: Data) -> [String : Any]? {
        do { // try to deserialize the data
            let json = try JSONSerialization.jsonObject(with: serializedJson, options: .mutableContainers)
            if Verbose.Active { NSLog("Log: Connection didFinishLoading. JSON: \(json)") }
            if let jsonObject = json as? [String : Any] {
                return jsonObject
            } else { return nil }
        } catch let error as NSError { NSLog("Error! JSON -> Dictionary serialization didFailWithError!\nError \(error.code) - \(error.localizedDescription))") }
        return nil
    }

    /**
     Function that serializes a JSON object
     - parameter json: The JSON object received for the body
     - returns: The JSON object serialized
     */
    func serialize(_ json: [String : Any]) -> Data? {
        do { // try to serialize the data
            return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        } catch let error as NSError { NSLog("Error! Dictionary -> JSON serialization didFailWithError!\nError \(error.code) - \(error.localizedDescription)") }
        return nil
    }
}
