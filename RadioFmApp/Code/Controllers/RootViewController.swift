//
//  RootViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import StoreKit

class RootViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Properties

    /** Property that represents the list of time intervals for the picker */
    private var timeIntervals = ["15 minutes", "30 minutes", "45 minutes", "1 hour", "2 hours", "3 hours"]
    /** Property that represents the selected row */
    private var selectedRow = 0

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Setup observers and push launch view controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.popToHomeScreen(_:)), name: .homeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.swapBackButton(_:)), name: .swapBackButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectMenuItem(_:)), name: .selectMenuItem, object: nil)
        self.push("LaunchViewController", animated: false)
    }

    // MARK: - Inherited functions from UIPicker data source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timeIntervals.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.timeIntervals[row]
    }

    // MARK: - Inherited functions from UIPicker delegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }

    // MARK: - Notification observers

    /**
     Function that handle the selected menu item
     - parameter notification: The notification object received
     */
    @objc func selectMenuItem(_ notification: Notification) {
        if notification.name == .selectMenuItem {
            if let row = notification.object as? Int {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                var viewController: UIViewController? = nil
                switch row {
                    case 0: // stations
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        UserDefaults.standard.set(false, forKey: "isFavorites")
                        break
                    case 1: // favorites
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        UserDefaults.standard.set(true, forKey: "isFavorites")
                        break
                    case 2: // Top 20
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 3: // rate app
                        self.requestReview()
                        break
                    case 4: // share
                        self.shareApp()
                        break
                    case 5: // sleep
                        self.presentPickerView()
                        break
                    default: break
                }
                if let controller = viewController{ // push view controller
                    controller.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.setBarButton("MenuButton")
                }
                self.menuWillShow(nil)
            }
        }
    }

    /**
     Function that shows/hides the left-side menu
     - parameter notification: The notification object received
     */
    @objc func swapBackButton(_ notification: Notification) {
        if notification.name == .swapBackButton {
            let menuTitles = ["Stations", "Favorites", "Top 20", "Rate App", "Share", "Sleep"]
//            let titleView = self.navigationController?.topViewController?.navigationItem.titleView
            let navigationTitle = self.navigationController?.topViewController?.navigationItem.title
            if navigationTitle != nil && menuTitles.contains(navigationTitle!) {
                self.setBarButton("MenuButton")
                if self.navigationController?.topViewController?.navigationItem.rightBarButtonItem != nil {
                    self.navigationController?.topViewController?.navigationItem.rightBarButtonItem?.customView?.isHidden = false
                }
            } else { self.setBarButton("BackButton") }
        }
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
     Function that adds a picker view as input view for textField
     - returns: The picker view created
     */
    private func getPickerView() -> UIPickerView {
        let pickerView = UIPickerView(frame: CGRect(x: 16, y: 20, width: 230, height: 150))
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }

    /**
     Function that shows/hides the left-side menu
     - parameter sender: The identifier of the sender of the action
     */
    @objc private func menuWillShow(_ sender: UIButton?) {
        NotificationCenter.default.post(name: .toggleMenu, object: sender != nil)
    }

    /**
     Function that pops to the root and pushes main view controller
     - parameter notification: The notification object received
     */
    @objc func popToHomeScreen(_ notification: Notification) {
        if notification.name == .homeNotification {
            self.push("TableViewController", animated: false)
            self.menuWillShow(nil)
        }
    }

    /**
     Function that presents a picker view
     */
    private func presentPickerView() {
        let alertController = UIAlertController(title: "Please select a time interval", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alertController.isModalInPopover = true
        alertController.view.addSubview(self.getPickerView())
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            NSLog("[UIPickerView] Log: User selected \(self.timeIntervals[self.selectedRow])...")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.navigationController?.topViewController?.present(alertController, animated: true, completion: nil)
    }

    /**
     Function that presents a view controller with a name and animation
     - parameter identifier: The name of the view controller that needs to be presented
     - parameter animated: Wheter is animation or not
     */
    private func push(_ identifier: String, animated: Bool) {
        if self.navigationController?.topViewController != self { self.navigationController?.popToRootViewController(animated: false) }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController?
        if identifier == "TableViewController" { // main
            viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            UserDefaults.standard.set(false, forKey: "isFavorites")
        } else if identifier == "LaunchViewController" { // launch
            viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        } else { viewController = nil }
        if let viewController = viewController { // push view controller
            if identifier != "LaunchViewController" { // if main view, push it with navigation controller
                viewController.navigationItem.hidesBackButton = true
                self.navigationController?.pushViewController(viewController, animated: animated)
                self.setBarButton("MenuButton")
            } else { self.present(viewController, animated: animated, completion: nil) }
        } else { NSLog("Error: Invalid View controller identifier: \(identifier)") }
    }

    /**
     Function that request a review
     */
    private func requestReview() {
        if #available(iOS 10.3, *) { // iOS 10.3 in advance
            DispatchQueue.main.async { SKStoreReviewController.requestReview() }
        } else { // Fallback on earlier versions
            let appStoreLink = "https://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
            if let url = URL(string: appStoreLink) { _ = NetworkUtils.shared.open(url) } // apple store
        }
    }

    /**
     Function that creates and sets the left bar button item
     - parameter identifier: The identifier of the button
     */
    private func setBarButton(_ identifier: String) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = nil
        if identifier == "MenuButton" { // create and show Menu button
            button.addTarget(self, action: #selector(menuWillShow(_:)), for: .touchUpInside)
            button.setImage(UIImage(named: "menu"), for: .normal)
            button.contentMode = .center
        } else { // Create and show Back button
            button.addTarget(self.navigationController?.topViewController, action: #selector(didPressBack(_:)), for: .touchUpInside)
            button.setImage(UIImage(named: "arrow_back"), for: .normal)
            button.contentMode = .scaleAspectFit
        }
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }

    /**
     Function that presents a popover to share app
     */
    private func shareApp() {
        let activityItems = [Api.ErrorDomain, "https://itunes.apple.com/us/app/apple-store/id375380948?mt=8"]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
