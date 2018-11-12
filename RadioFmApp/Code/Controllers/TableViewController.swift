//
//  TableViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 28/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Crashlytics
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

    /** Property that represents the label for the error message */
    @IBOutlet weak var labelMessage: UILabel!
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
    private var stations = [String]()
    /** Property that represents the list of images names for the menu */
    private var urls = [String]()
    /** Property that represents wheter is playing radio or not */
    private var isPlaying = false
    /** Property that represents wheter is favorite screen or not */
    private var isFavorites = false
    /** Property that represents the selected row */
    private var selectedRow = 0

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.isPlaying = UserDefaults.standard.bool(forKey: "isPlaying")
        self.isFavorites = UserDefaults.standard.bool(forKey: "isFavorites")
        self.navigationController?.topViewController?.navigationItem.title = self.isFavorites ? "Favorites" : "Stations"

        // Setup table view controller and model
        if self.isFavorites { // favorites screen
            LocalDatabase.standard.load(0)
            LocalDatabase.standard.load(1)
            self.stations = LocalDatabase.standard.favorites as! [String]
            self.urls = LocalDatabase.standard.favoritesUrl as! [String]
        } else { // home screen
            self.stations = ["Megastar FM", "RPA Radio", "RNE", "Ibiza Sonica Radio", "RAC 105", "Cadena Ser", "Radio Voz", "Radio Galaxia"]
            self.urls = ["http://195.10.10.222/cope/megastar.aac?GKID=d51d8e14d69011e88f2900163ea2c744", "http://195.55.74.203/rtpa/live/radio.mp3?GKID=280fad92d69a11e8b65b00163e914", "http://rne-hls.flumotion.com/playlist.m3u8", "http://94.75.227.133:1025/", "http://rac105.radiocat.net/", "http://playerservices.streamtheworld.com/api/livestream-redirect/CADENASERAAC_SC", "http://live.radiovoz.es/coruna/master.m3u8", "http://radios-ec.cdn.nedmedia.io/radios/ec-galaxia.m3u8"]
        }
        self.labelMessage.text = "No radio stations found.".uppercased()
        self.labelMessage.isHidden = self.stations.count > 0
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.isHidden = self.stations.count <= 0
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Setup footer for player
        self.labelStation.text = "RadiOS FM"
        self.iconStation.image = UIImage(named: "radio")
        self.iconPlay.image = UIImage(named: "play")
        self.iconPlay.isUserInteractionEnabled = true
        self.footer.isHidden = self.stations.count <= 0
        let tapToggle = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        tapToggle.numberOfTouchesRequired = 1
        tapToggle.numberOfTapsRequired = 1
        self.iconPlay.addGestureRecognizer(tapToggle)
        if self.isPlaying { self.refresh() }

        // Swap Back button
        NotificationCenter.default.post(name: .swapBackButton, object: nil)
    }

    // MARK: - Inherited functions from UITableView data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView = tableView
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewCell", for: indexPath) as? MainViewCell {
            cell.iconView.image = UIImage(named: "radio")
            cell.iconView = ColorUtils.shared.renderImage(cell.iconView, color: .lightGray, userInteraction: true)
            cell.labelTitle.text = NSLocalizedString(self.stations[indexPath.row], comment: Tag.Empty)
            cell.starView = self.toggle(cell.starView, selected: cell.isFavorite)
            cell.starView.addGestureRecognizer(self.getGesture())
            cell.labelTitle.adjustsFontSizeToFitWidth = true
            cell.starView.isUserInteractionEnabled = true
            cell.labelTitle.textColor = .gray
            cell.labelTitle.numberOfLines = 0
            cell.starView.tag = indexPath.row
            cell.backgroundColor = .white
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stations.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // MARK: - Inherited functions from UITableView delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UserDefaults.standard.set(self.stations[indexPath.row], forKey: "selectedStation")
        self.selectedRow = indexPath.row
        self.play(indexPath.row)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.isFavorites
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if self.isFavorites && editingStyle == .delete { self.deleteRowAt(indexPath) }
    }

    // MARK: - Inherited functions from RadioUtils delegate

    func util(_ util: RadioUtils, playerStateChanged state: FRadioPlayerState) {
        switch state {
        case .error:
            NSLog("[FRadioPlayer] Error! Player failed to load!")
            let userInfo = [NSLocalizedDescriptionKey : "RadioUtils - Player failed to load",
                            NSLocalizedFailureReasonErrorKey : "500 - Player failed to load"]
            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
            break
        case .loading:
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Player is loading...") }
            break
        case .loadingFinished:
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Player finished loading...") }
            UserDefaults.standard.set(true, forKey: "isPlaying")
            self.isPlaying = true
            self.refresh()
            break
        case .readyToPlay:
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Player is ready to play...") }
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
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Received metadata - \(value)") }
            DispatchQueue.main.async { self.labelStation.text = value }
        }
    }

    // MARK: - Inherited functions from UITap gesture recognizers

    /**
     Function that handles the tap gesture
     - parameter sender: The tap gesture recognizer
     */
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        if self.isPlaying {
            RadioUtils.shared.stop()
            self.isPlaying = false
            self.refresh()
        } else { self.play(self.selectedRow) }
        UserDefaults.standard.set(self.isPlaying, forKey: "isPlaying")
    }

    /**
     Function that handles the tap gesture
     - parameter sender: The tap gesture recognizer
     */
    @objc func didTapFavorite(_ sender: UITapGestureRecognizer) {
        if let row = sender.view?.tag {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tableView.cellForRow(at: indexPath) as? MainViewCell {
                if !self.isFavorites {
                    if cell.isFavorite {
                        cell.isFavorite = false
                    } else { cell.isFavorite = true }
                    cell.starView = self.toggle(cell.starView, selected: cell.isFavorite)
                    self.populateFavorites(indexPath.row, isAdding: cell.isFavorite)
                } else { self.deleteRowAt(indexPath) } // favorite screen
            }
        }
    }

    // MARK: - Functions

    /**
     Function that deletes a row
     - parameter indexPath: The indexPath of the cell
     */
    private func deleteRowAt(_ indexPath: IndexPath) {
        if indexPath.row < self.urls.count {
            self.populateFavorites(indexPath.row, isAdding: false)
            self.stations.remove(at: indexPath.row)
            self.urls.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
    }

    /**
     Function that gets a tap gesture recognizer
     - returns: The tap gesture recognizer
     */
    private func getGesture() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFavorite(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }

    /**
     Function that plays the radio station
     - parameter row: The row of the cell
     */
    private func play(_ row: Int) {
        if row < self.urls.count {
            RadioUtils.shared.configure(self.urls[row])
            RadioUtils.shared.delegate = self
        } else {
            NSLog("Error! Cell indexPath.row out of bounds!")
            let userInfo = [NSLocalizedDescriptionKey : "Play - Cell indexPath.row out of bounds",
                            NSLocalizedFailureReasonErrorKey : "404 - Cell indexPath.row out of bounds"]
            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
        }
    }

    /**
     Function that populates the favorites list
     - parameter row: The row of the cell
     - parameter isAdding: Whether is adding new or not
     */
    private func populateFavorites(_ row: Int, isAdding: Bool) {
        if row < self.urls.count {
            let station = self.stations[row]
            let url = self.urls[row]
            if !isAdding { // remove
                LocalDatabase.standard.remove(station, url: url)
            } else { LocalDatabase.standard.add(station, url: url) } // add
        } else {
            NSLog("Error! Cell indexPath.row out of bounds!")
            let userInfo = [NSLocalizedDescriptionKey : "Populate Favorites - Cell indexPath.row out of bounds",
                            NSLocalizedFailureReasonErrorKey : "404 - Cell indexPath.row out of bounds"]
            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
        }
    }

    /**
     Function that refreshes the player footer
     */
    private func refresh() {
        DispatchQueue.main.async {
            self.iconPlay.image = UIImage(named: self.isPlaying ? "pause" : "play")
            let station = UserDefaults.standard.string(forKey: "selectedStation")
            self.labelStation.text = self.isPlaying ? station : "RadiOS FM"
        }
    }

    /**
     Function that refreshes the artwork
     - parameter url: The url or the artwork
     */
    private func refreshArtwork(_ url: URL) {
        do { // download image
            let data = try Data(contentsOf: url)
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Received artwork @ \(url.absoluteString)") }
            DispatchQueue.main.async { self.iconStation.image = UIImage(data: data) }
        } catch { NSLog("Exception! An error ocurred trying to load the contents of an URL! Hint:\(error.localizedDescription)") }
    }

    /**
     Function that toggles an image view
     - parameter imageView: The image view to toggle
     - parameter selected: Whether is selected or not
     - returns: The image view toggled
     */
    private func toggle(_ imageView: UIImageView, selected: Bool) -> UIImageView {
        var customView = imageView
        if self.isFavorites { // favorites
            customView.image = UIImage(named: "rubbish")
            customView = ColorUtils.shared.renderImage(customView, color: selected ? .red : Color.k1097FB, userInteraction: true)
        } else { // home screen
            customView.image = UIImage(named: selected ? "star_full" : "star_empty")
            if !selected { customView = ColorUtils.shared.renderImage(customView, color: Color.k1097FB, userInteraction: true) }
        }
        return customView
    }
}
