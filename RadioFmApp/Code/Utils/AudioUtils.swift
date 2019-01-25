//
//  AudioUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Mute
import Crashlytics
import MediaPlayer
import AVFoundation

protocol AudioDelegate: class {
    
    /**
     This method is invoked wheter the player can/cannot speak.
     - parameter util: The util component
     - parameter success: The result of the play
     */
    func util(_ util: AudioUtils, canSpeak success: Bool)
    
    /**
     This method is invoked when the player did finish playing.
     - parameter util: The util component
     - parameter success: The result of the play
     */
    func util(_ util: AudioUtils, didFinish success: Bool)
}

class AudioUtils: NSObject, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {

    // MARK: - Properties

    /** Property that represents the delegate of the utils */
    weak var delegate: AudioDelegate?
    /** Property that represents the audio player */
    private var player: AVAudioPlayer?
    /** Property that represents the audio synthesizer */
    private var synthesizer: AVSpeechSynthesizer?
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

    static let shared = AudioUtils()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Inherited function from AVAudioPlayer delegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.deactivateSession()
        if Verbose.Active { NSLog(flag ? "[AVAudioPlayer] Log: Player finished playing..." : "[AVAudioPlayer] Warning: Something happened while playing...") }
        self.delegate?.util(self, didFinish: flag)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if player.isPlaying { player.stop() }
        if let error = error as NSError? {
            NSLog("[AVAudioPlayer] Error \(error.code) - \(error.localizedDescription)")
            self.delegate?.util(self, didFinish: false)
            Crashlytics.sharedInstance().recordError(NSError(domain: "AVAudioPlayer", code: error.code, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription]))
        }
    }

    // MARK: - Inherited function from Speech synthesizer delegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: didStart...") }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: didPause...") }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: didCancel...") }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: didContinue...") }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: didFinish...") }
        self.delegate?.util(self, didFinish: true)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: willSpeakRangeOfSpeechString...") }
    }

    // MARK: - Functions

    /**
     Function that configures the audio util and device
     */
    func configure() {
        do { // try to get all configuration ready
            try activateSession()
        } catch { self.delegate?.util(self, canSpeak: false) } // handle error
        self.volumeChanged()
        self.muteSwitchWillUpdate()
    }

    /**
     Function that deactivates the audio util
     */
    func deactivate() {
        self.deactivateSession()
        self.delegate = nil
    }

    /**
     Function that speaks the message received
     - parameter message: The string-value for the message
     */
    func speak(_ message: String) {
        if Verbose.Active { NSLog("[AVSpeechSynthesizer] Log: Speak \(message)...") }
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer!.delegate = self
        self.synthesizer!.speak(utterance)
    }

    // MARK: - Private functions

    /**
     Function that activates the audio session
     - throws: Set active error
     */
    private func activateSession() throws {
        let session = AVAudioSession.sharedInstance()
        do { // Try to setup the audio sesion and read the volume
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            self.outputVolume = session.outputVolume
        } catch { // exception catched
            let userInfo = [NSLocalizedDescriptionKey : error.localizedDescription]
            NSLog("[AVAudioSession] Error! An error ocurred activating the audioSession. Error 500 - \(error.localizedDescription)")
            Crashlytics.sharedInstance().recordError(NSError(domain: "AVAudioSession", code: 500, userInfo: userInfo))
        }
    }

    /**
     Function that deactivates the audio session
     */
    private func deactivateSession() {
        if let synthesizer = self.synthesizer { // stop synthesizer
            if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
            synthesizer.delegate = nil
            self.synthesizer = nil
        }
        if let player = self.player { // stop player
            if player.isPlaying { player.stop() }
            player.delegate = nil
            self.player = nil
        }
        do { // Try to deactive the audio sesion
            let session = AVAudioSession.sharedInstance()
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        } catch { // exception catched
            let userInfo = [NSLocalizedDescriptionKey : error.localizedDescription]
            NSLog("[AVAudioSession] Error! An error ocurred deactivating the audioSession. Error 501 - \(error.localizedDescription)")
            Crashlytics.sharedInstance().recordError(NSError(domain: "AVAudioSession", code: 501, userInfo: userInfo))
        }
    }

    /**
     Function that checks if the volume is silenced
     */
    private func muteSwitchWillUpdate() {
        Mute.shared.isPaused = false
        Mute.shared.checkInterval = 1.0
        Mute.shared.alwaysNotify = true
        Mute.shared.notify = { silent in
            Mute.shared.isPaused = true
            if silent { // is silent
                NotificationCenter.default.post(name: .alertNotification, object:["SPEAKER_MUTED_TITLE", "SPEAKER_MUTED_DESC", "WTG_BUTTON_OK"])
            } else { self.delegate?.util(self, canSpeak: true) }
        }
    }

    /**
     Function that play the audio
     */
    private func play() {
        if let path = Bundle.main.path(forResource: "wtg-music", ofType: "wav") {
            do { // play the audio file
                self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                self.player!.delegate = self
                self.player!.play()
            } catch { // exception catched
                let userInfo = [NSLocalizedDescriptionKey : error.localizedDescription]
                NSLog("[AVAudioPlayer] Error! An error occurred trying to init the player. Error 502 - \(error.localizedDescription)")
                Crashlytics.sharedInstance().recordError(NSError(domain: "AVAudioPlayer", code: 502, userInfo: userInfo))
            }
        }
    }

    /**
     Function that checks if the volume changed
     */
    private func volumeChanged() {
        let isTooLow = self.outputVolume < self.minVolume
        if isTooLow { self.volumeWillChange() }
    }

    /**
     Function that configures the volume
     */
    private func volumeWillChange() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if view is UISlider {
                if let slider = view as? UISlider {
                    self.oldVolume = slider.value == 0.0 ? 0.2 : slider.value
                    slider.value = 0.6
                }
            }
        }
    }
}
