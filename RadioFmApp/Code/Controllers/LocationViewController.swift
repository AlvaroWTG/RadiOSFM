//
//  LocationViewController.swift
//  RadioFmApp
//
//  Created by WebToGo on 11/13/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit

class LocationViewCell: UITableViewCell {

    // MARK: - Properties

    /** Property that represents the label for the cell */
    @IBOutlet weak var labelTitle: UILabel!
}

    // MARK: - Properties

    /** Property that represents the table view for the screen */
    @IBOutlet weak var tableView: UITableView!
    /** Property that represents the button for the screen */
    @IBOutlet weak var button: UIButton!
    /** Property that represents the location manager of the device */
    private var manager = CLLocationManager()

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
