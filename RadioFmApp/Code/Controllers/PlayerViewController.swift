//
//  PlayerViewController.swift
//  RadioFmApp
//
//  Created by WebToGo on 11/13/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    // MARK: - Properties

    /** Property that represents the header for the advertising */
    @IBOutlet weak var headerMarketing: UIView!
    /** Property that represents the image view for the player */
    @IBOutlet weak var imageView: UIImageView!
    /** Property that represents the label for the player */
    @IBOutlet weak var labelPlayer: UILabel!
    /** Property that represents the image view for the favorite option */
    @IBOutlet weak var imageFavorite: UIImageView!
    /** Property that represents the view for the play button */
    @IBOutlet weak var viewPlay: UIView!
    /** Property that represents the icon for the play button */
    @IBOutlet weak var iconPlay: UIImageView!

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
