//
//  NetworkUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Foundation
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

    /**
     Function that obtains the current IP address of the device
     - returns: The current IP address of the device
     */
    func getIpAddress() -> String? {
        let wifiAddress = self.getIpAddressFor("wifi")
        let cellularAddress = self.getIpAddressFor("cellular")
        let result = wifiAddress ?? cellularAddress
        return result ?? "0.0.0.0"
    }

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
    @objc func reachabilityChanged(_ notification: Notification) {
        if notification.name == .reachabilityChanged {
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
     Function that reads the status bar
     - parameter keySubview: The subview key to look for
     - parameter key: The item key to look for
     - returns: The nsnumber result
     */
    private func readStatusBar(_ keySubview: String, key: String) -> Int {
        var statusBarItem: UIView?
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            NSLog("[Network] Error! Invalid raw value for statusBarWindow.statusBar!")
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
        if statusBarItem == nil { // if invalid status bar item
            NSLog("[Network] Error! Invalid statusBarItem obtained!")
            return 0
        } else { return statusBarItem?.value(forKey: key) as! Int }
    }

    /**
     Function that evaluates reachability and start the notifier
     */
    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachability)
        do { // setup reachability
            self.reachability = Reachability()!
            try self.reachability.startNotifier()
            self.isLive = true
        } catch { NSLog("[Reachability] Error 404 - Could not start reachability notifier!") }
    }
}
