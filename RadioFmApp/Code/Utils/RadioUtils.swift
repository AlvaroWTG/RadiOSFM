//
//  RadioUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 28/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import FRadioPlayer

protocol RadioDelegate: class {

    /**
     This method is invoked when the util receives a response.
     - parameter util: The util instance that handles communication
     - parameter error: The error value of the response
     - parameter message: The string value of the message
     */
    func util(_ util: RadioUtils, playerStateChanged state: FRadioPlayerState)
    
    func util(_ util: RadioUtils, metadataChanged rawValue: String?, url: URL?)
}

class RadioUtils: NSObject, FRadioPlayerDelegate {

    // MARK: - Properties

    /** Property that represents the delegate of this util class */
    weak var delegate: RadioDelegate?
    /** Property that represents the radio player */
    private var player: FRadioPlayer?
    /** Property that represents the current volume */
    private var outputVolume: Float = 0.0
    /** Property that represents the minimum volume threshold */
    private var minVolume: Float = 0.0
    /** Property that represents the old volume of the audio player */
    private var oldVolume: Float = 0.0
    /** Property that represents the flag whether the volume is too low or not */
    private var isTooLow: Bool = false
    /** Property that represents the flag whether the device is muted or not */
    private var isMuted: Bool = false

    // MARK: - Singleton

    static let shared = RadioUtils()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Inherited function from FRadioPlayer delegate

    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        if self.delegate != nil { self.delegate?.util(self, playerStateChanged: state) }
    }

    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        switch state {
            case .playing:
                NSLog("[FRadioPlayer] Log: playback state changed to PLAYING")
                break
            case .paused:
                NSLog("[FRadioPlayer] Log: playback state changed to PAUSED")
                break
            case .stopped:
                NSLog("[FRadioPlayer] Log: playback state changed to STOPPED")
                break
            default: break
        }
    }

    func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
        if Verbose.Active { NSLog("[FRadioPlayer] Log: item changed @ \(url?.absoluteString ?? "unknown URL")") }
    }

    func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?) {
        if self.delegate != nil { self.delegate?.util(self, metadataChanged: rawValue, url: nil) }
    }

    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        if self.delegate != nil { self.delegate?.util(self, metadataChanged: nil, url: artworkURL) }
    }

    // MARK: - Functions

    /**
     Function that configures the audio util and device
     */
    func configure() {
        if let player = FRadioPlayer.shared {
            player.delegate = self
            player.radioURL = URL(string: "http://example.com/station.mp3")
            self.player = player
            self.player?.play()
        }
    }
}
