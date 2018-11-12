//
//  RootViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

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
                    case 0: // home / contract
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 1: // avb / terms
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 2: // terms / privacy
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 3: // privacy / faq
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 4: // faq / email
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 5: // email / phone
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 6: // phone / about us
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    case 7: // about us
                        viewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
                        break
                    default: break
                }
                if viewController != nil { // push view controller
                    viewController?.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(viewController!, animated: true)
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
            let titleView = self.navigationController?.topViewController?.navigationItem.titleView
            let navigationTitle = self.navigationController?.topViewController?.navigationItem.title
            if navigationTitle == Tag.Empty || titleView != nil {
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
}
