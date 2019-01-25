//
//  RadioUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 28/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import FRadioPlayer

struct WatchDog {

    // MARK:- Properties

    /** Property that represents the the data created of daemon */
    private let created = Date()

    // MARK:- API

    /**
     Function that logs the duration in miliseconds
     */
    func logDuration() {
        let diff = Date().timeIntervalSince(self.created)
        NSLog("[WatchDog] Log: Station loaded in \(diff * 1000) ms...")
    }
}

protocol RadioDelegate: class {

    /**
     This method is invoked when the player state changed.
     - parameter util: The util instance that handles radio
     - parameter state: The new state that the player is now
     */
    func util(_ util: RadioUtils, playerStateChanged state: FRadioPlayerState)

    /**
     This method is invoked when the util receives metadata.
     - parameter util: The util instance that handles radio
     - parameter rawValue: The raw value of the metadata
     - parameter url: The url that may contain new information
     */
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
    /** Property that represents the flag whether the device is muted or not */
    private var watchDog: WatchDog?

    // MARK: - Singleton

    static let shared = RadioUtils()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Inherited function from FRadioPlayer delegate

    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        self.delegate?.util(self, playerStateChanged: state)
        if state == .loadingFinished { if let watchDog = self.watchDog { watchDog.logDuration() } }
    }

    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        switch state {
            case .playing:
                NSLog("[FRadioPlayer] Log: Playback is PLAYING...")
                break
            case .paused:
                NSLog("[FRadioPlayer] Log: Playback was PAUSED...")
                break
            case .stopped:
                NSLog("[FRadioPlayer] Log: Playback has STOPPED...")
                break
            default: break
        }
    }

    func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
        if Verbose.Active { NSLog("[FRadioPlayer] Log: Loading radio station @ \(url?.absoluteString ?? "unknown URL")") }
    }

    func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?) {
        self.delegate?.util(self, metadataChanged: rawValue, url: nil)
    }

    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        self.delegate?.util(self, metadataChanged: nil, url: artworkURL)
    }

    // MARK: - Functions

    /**
     Function that configures the audio util and device
     */
    func configure(_ station: Station) {
//        self.watchDog = WatchDog()
//        self.player = FRadioPlayer.shared
//        player!.radioURL = URL(string: station.url)
//        player!.delegate = self
    }

    /**
     Function that plays the radio station
     */
    func play() {
        if let player = self.player {
            if !player.isPlaying { player.play() }
        }
    }

    /**
     Function that stops the radio station
     */
    func stop() {
        if let player = self.player {
            if player.isPlaying { player.stop() }
        }
    }
}
