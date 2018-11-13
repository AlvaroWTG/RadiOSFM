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

    /** Property that represents the selected station */
    var station = Station()
    /** Property that represents whether is playing or not */
    var isPlaying = false
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

        // Setup navigation bar for the view controller
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.topViewController?.navigationItem.title = self.station.name

        // Setup view controller content
        self.headerMarketing.backgroundColor = .lightGray
        self.imageView.image = UIImage(named: self.station.iconName)
        self.labelPlayer.text = "\(self.station.name)\n\(self.station.popularity)"
        self.imageFavorite.image = UIImage(named: self.station.isFavorite ? "star_full" : "star_empty")
        self.imageView = ColorUtils.shared.renderImage(self.imageView, color: .lightGray, userInteraction: true)
        if !self.station.isFavorite { self.imageFavorite = ColorUtils.shared.renderImage(self.imageFavorite, color: Color.k1097FB, userInteraction: true) }

        // Setup button play view
        self.iconPlay.image = UIImage(named: self.isPlaying ? "pause" : "play")
        self.viewPlay.layer.cornerRadius = self.viewPlay.frame.width / 2
        self.viewPlay.clipsToBounds = true

        // Swap Back button
        NotificationCenter.default.post(name: .swapBackButton, object: nil)
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
}
