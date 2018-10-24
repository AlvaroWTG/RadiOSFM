//
//  AudioUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 24/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Mute
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

class AudioUtils: NSObject {

}
