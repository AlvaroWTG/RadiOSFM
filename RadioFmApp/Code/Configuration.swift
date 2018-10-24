//
//  Configuration.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//
import UIKit

// MARK: - VERBOSE

// Constants for backup type values
struct Verbose {
    static let Active = true
}

// MARK: - EXTENSIONS

extension UIApplication {
    var statusBarView: UIView? { return value(forKey: "statusBar") as? UIView }
    var statusBarModern: UIView? { return value(forKey: "UIStatusBar_Modern") as? UIView }
}

extension Notification.Name {
    public static let alertNotification = Notification.Name("alertNotification")
}

// MARK: - STRUCTURES

// Constants for color definitions used in the app
struct Color {
    static let k333333 = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1) // protectonaut dark grey
    static let k64E2E0 = UIColor(red: 100/255, green: 226/255, blue: 224/255, alpha: 1) // protectonaut light blue
    static let k112E6A = UIColor(red: 17/255, green: 46/255, blue: 106/255, alpha: 1) // protectonaut blue
    static let kEB004E = UIColor(red: 235/255, green: 0/255, blue: 78/255, alpha: 1) // protectonaut red
    static let kE7B639 = UIColor(red: 231/255, green: 182/255, blue: 57/255, alpha: 1) // protectonaut accent yellow
}
