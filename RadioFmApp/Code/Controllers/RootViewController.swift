//
//  RootViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import FRadioPlayer

class RootViewController: UIViewController, RadioDelegate {

    // MARK: - Properties

    /** Property that represents the button for the view */
    @IBOutlet weak var button: UIButton!
    /** Property that represents the image view for the view */
    @IBOutlet weak var imageView: UIImageView!
    /** Property that represents the label for the artwork */
    @IBOutlet weak var labelArtwork: UILabel!

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.topViewController?.navigationItem.title = "RadiOS FM"
        self.button.setTitle("PLAY", for: .normal)
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
            DispatchQueue.main.async { self.labelArtwork.text = value }
        }
    }

    // MARK: - IBAction function implementation

    /**
     Function that performs an action when the menu button is clicked
     - parameter sender: The identifier of the sender of the action
     */
    @IBAction func didPress(_ sender: UIButton) {
        let urls = ["http://195.10.10.222/cope/megastar.aac?GKID=d51d8e14d69011e88f2900163ea2c744", "http://195.55.74.203/rtpa/live/radio.mp3?GKID=280fad92d69a11e8b65b00163e914", "http://rne-hls.flumotion.com/playlist.m3u8", "http://94.75.227.133:1025/", "http://rac105.radiocat.net/", "http://playerservices.streamtheworld.com/api/livestream-redirect/CADENASERAAC_SC", " http://live.radiovoz.es/coruna/master.m3u8", "http://radios-ec.cdn.nedmedia.io/radios/ec-galaxia.m3u8"]
        RadioUtils.shared.configure(urls[7])
        RadioUtils.shared.delegate = self
    }
    
    
    // MARK: - IBAction function implementation

    /**
     Function that refreshes the artwork
     - parameter url: The url or the artwork
     */
    private func refreshArtwork(_ url: URL) {
        do { // download image
            let data = try Data(contentsOf: url)
            NSLog("[FRadioPlayer] Log: Received artwork @ \(url.absoluteString)")
            DispatchQueue.main.async { self.imageView.image = UIImage(data: data) }
        } catch { NSLog("Exception!") }
    }
}
