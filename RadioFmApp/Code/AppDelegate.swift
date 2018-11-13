//
//  AppDelegate.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import ViewDeck

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    /** Property that represents the window of the device */
    var window: UIWindow?
    /** Property that represents the view deck controller of the app */
    var viewDeck: IIViewDeckController? = nil
    /** Property that represents whether the app just started or not */
    var applicationIsActive = false
    /** Property that represents whether the app enables all orientation or not */
    var enableAllOrientation = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Initialize Fabric
        if Verbose.Active { NSLog("[Fabric] Fabric crashlytics kit enabled") }
        Fabric.with([Crashlytics()])

        // Setup observers and battery monitoring
        NotificationCenter.default.addObserver(self, selector: #selector(powerStateChanged(_:)), name: .NSProcessInfoPowerStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleMenu(_:)), name: .toggleMenu, object: nil)
        UserDefaults.standard.set(Tag.Empty, forKey: "selectedStation")
        UserDefaults.standard.set(true, forKey: "applicationIsFresh")
        UserDefaults.standard.set(false, forKey: "isPlaying")
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.applicationIsActive = true

        // Storyboard, Navigation and root view controller
        self.initStoryboard()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        NSLog("[UIApplication] Log: Application will resign active...")
        self.applicationIsActive = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSLog("[UIApplication] Log: Application did enter background...")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("[UIApplication] Log: Application did become active...")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSLog("[UIApplication] Log: Application will terminate...")
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if enableAllOrientation { // enable all orientations
            return UIInterfaceOrientationMask.allButUpsideDown
        } else { return UIInterfaceOrientationMask.portrait }
    }

    // MARK: - Functions

    /**
     Function that setups the storyboard
     */
    private func initStoryboard() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        UIApplication.shared.statusBarView?.backgroundColor = Color.k1097FB
        UINavigationBar.appearance().barTintColor = Color.k1097FB
        UINavigationBar.appearance().tintColor = .white

        // Setup Menu Controller Using ViewDeckController and Nib's From Storyboard
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let width = self.window!.frame.size.width - CGFloat(40.0)
        let navigationController = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "RootViewController"))
        let sideViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController")
        sideViewController.preferredContentSize = CGSize(width: width, height: self.window!.frame.size.height)
        self.viewDeck = IIViewDeckController(center: navigationController, leftViewController: sideViewController)
        self.viewDeck?.isPanningEnabled = false

        // Set ViewDeckController As RootViewController
        self.window?.rootViewController = self.viewDeck
        self.window?.makeKeyAndVisible()
    }

    /**
     Function that receives notifiction when the power mode changed
     - parameter notification: The notification object received
     */
    @objc func powerStateChanged(_ notification: Notification) {
        if notification.name == .NSProcessInfoPowerStateDidChange {
            let isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
            if Verbose.Active {
                let messageEnable = "Low Power Mode is enabled. Reduce activity to conserve energy."
                NSLog(isLowPowerModeEnabled ? messageEnable : "Low Power Mode is not enabled.")
            }
        }
    }

    /**
     Function that toggle left view controller with animation
     - parameter notification: The notification object received
     */
    @objc func toggleMenu(_ notification: Notification) {
        if notification.name == .toggleMenu {
            if notification.object as! Bool { // open
                self.viewDeck?.open(.left, animated: true)
            } else { self.viewDeck?.closeSide(true) }
        }
    }
}

