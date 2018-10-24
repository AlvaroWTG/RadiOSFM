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

// Constants for string tags
struct Tag {
    static let At = "@"
    static let Blank = " "
    static let BlankSlash = " |"
    static let Br = "<br>"
    static let Button = "button"
    static let Config = "tests_config"
    static let Comma = ","
    static let Dialog = "dialog"
    static let Dot = "."
    static let Empty = ""
    static let ErrorFormat = "[Bundle] Error! An error ocurred getting the data. Hint: "
    static let Filter = "filter"
    static let Fix = "fix"
    static let Flow = "flow"
    static let HundredK = "100000"
    static let Issues = "issue_tree"
    static let Item = "item"
    static let Minus = "-"
    static let NewLine = "\n"
    static let Plus = "+"
    static let Prereqs = "prereqs"
    static let Results = "results_evaluation"
    static let Slash = "|"
    static let SlashDouble = "||"
    static let Slash2 = "/"
    static let Solutions = "solutions"
    static let Test = "test"
    static let TestGroup = "test_group"
    static let TestOk = "test_ok"
    static let Unknown = "unknown"
    static let Value = "value"
    static let WhiteList = "white_list_app"
    static let XML = "xml"
}
