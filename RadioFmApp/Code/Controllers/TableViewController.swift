//
//  TableViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 28/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import FRadioPlayer

class MainViewCell: UITableViewCell {

    // MARK: - Properties

    /** Property that represents the label for the user */
    @IBOutlet weak var labelTitle: UILabel!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconView: UIImageView!
    /** Property that represents the image view for the user */
    @IBOutlet weak var starView: UIImageView!
    /** Property that represents wheter is favorite or not */
    var isFavorite = false
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RadioDelegate {

    // MARK: - Properties

    /** Property that represents wheter is favorite screen or not */
    private var isFavorites = false
    /** Property that represents the image view for the view */
    @IBOutlet weak var tableView: UITableView!
    /** Property that represents the label for the user */
    @IBOutlet weak var footer: UIView!
    /** Property that represents the label for the user */
    @IBOutlet weak var labelStation: UILabel!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconStation: UIImageView!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconPlay: UIImageView!
    /** Property that represents the list of titles for the menu */
    private var titles = [String]()
    /** Property that represents the list of images names for the menu */
    private var urls = [String]()

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.topViewController?.navigationItem.title = "RadiOS FM"

        // Setup table view controller and model
        self.titles = ["Megastar FM", "RPA Radio", "RNE", "Ibiza Sonica Radio", "RAC 105", "Cadena Ser", "Radio Voz", "Radio Galaxia"]
        self.urls = ["http://195.10.10.222/cope/megastar.aac?GKID=d51d8e14d69011e88f2900163ea2c744", "http://195.55.74.203/rtpa/live/radio.mp3?GKID=280fad92d69a11e8b65b00163e914", "http://rne-hls.flumotion.com/playlist.m3u8", "http://94.75.227.133:1025/", "http://rac105.radiocat.net/", "http://playerservices.streamtheworld.com/api/livestream-redirect/CADENASERAAC_SC", "http://live.radiovoz.es/coruna/master.m3u8", "http://radios-ec.cdn.nedmedia.io/radios/ec-galaxia.m3u8"]
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Setup footer for player
        self.iconStation.image = UIImage(named: "")
        self.iconPlay.image = UIImage(named: "play")
        self.labelStation.text = "RadiOS FM"

        // Swap Back button
        NotificationCenter.default.post(name: .swapBackButton, object: nil)
    }

    // MARK: - Inherited functions from UITableView data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView = tableView
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewCell", for: indexPath) as? MainViewCell {
            cell.labelTitle.text = NSLocalizedString(self.titles[indexPath.row], comment: Tag.Empty)
            cell.starView = self.toggle(cell.starView, selected: cell.isFavorite)
            cell.labelTitle.adjustsFontSizeToFitWidth = true
            cell.labelTitle.textColor = .gray
            cell.labelTitle.numberOfLines = 0
            cell.backgroundColor = .white
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // MARK: - Inherited functions from UITableView delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.play(indexPath.row)
    }

    // MARK: - Inherited functions from RadioUtils delegate

    func util(_ util: RadioUtils, playerStateChanged state: FRadioPlayerState) {
        switch state {
        case .error:
            NSLog("[FRadioPlayer] Error! Player failed to load!")
            break
        case .loading:
            NSLog("[FRadioPlayer] Log: Player is loading...")
            break
        case .loadingFinished:
            NSLog("[FRadioPlayer] Log: Player finished loading...")
            break
        case .readyToPlay:
            NSLog("[FRadioPlayer] Log: Player is ready to play...")
            break
        case .urlNotSet:
            NSLog("[FRadioPlayer] Log: Player has NO URL set...")
            break
        default: break
        }
    }

    func util(_ util: RadioUtils, metadataChanged rawValue: String?, url: URL?) {
        if let url = url { self.refreshArtwork(url) }
        if let value = rawValue {
            NSLog("[FRadioPlayer] Log: Received metadata - \(value)")
            DispatchQueue.main.async { self.labelStation.text = value }
        }
    }

    // MARK: - Functions

    /**
     Function that plays the radio station
     - parameter row: The row of the cell
     */
    private func play(_ row: Int) {
        RadioUtils.shared.configure(self.urls[row])
        RadioUtils.shared.delegate = self
        DispatchQueue.main.async {
            self.iconPlay.image = UIImage(named: "pause")
            self.labelStation.text = self.titles[row]
        }
    }

    /**
     Function that refreshes the artwork
     - parameter url: The url or the artwork
     */
    private func refreshArtwork(_ url: URL) {
        do { // download image
            let data = try Data(contentsOf: url)
            NSLog("[FRadioPlayer] Log: Received artwork @ \(url.absoluteString)")
            DispatchQueue.main.async { self.iconStation.image = UIImage(data: data) }
        } catch { NSLog("Exception!") }
    }

    /**
     Function that refreshes the artwork
     - parameter url: The url or the artwork
     */
    private func toggle(_ imageView: UIImageView, selected: Bool) -> UIImageView {
        var customView = imageView
        customView.image = UIImage(named: selected ? "star_full" : "star_empty")
        if !selected { customView = ColorUtils.shared.renderImage(customView, color: Color.k1097FB, userInteraction: true) }
        return customView
    }
}
