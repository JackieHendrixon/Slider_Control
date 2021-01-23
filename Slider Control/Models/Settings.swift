//
//  Settings.swift
//  Slider Control
//
//  Created by Franek on 30/03/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import Foundation
import UIKit




class Settings{
    
    var deviceName: String = " "
    
    // Application mode
    enum Mode {
        case sequence, live
    }
    
    var mode: Mode = .live
    
    // Timecode format changing
    enum TimecodeFormat {
        case totalFrames, minSecFrame
    }
    
    var timecodeFormat: TimecodeFormat = .totalFrames {
        didSet {
            NotificationCenter.default.post(name: .didChangeTimecodeFormat, object: nil)
        }
    }
    
    var framesPerSecond: Int = 24
    
    var joystickSize: Int = 100
    
}

extension NSNotification.Name {
    static let didChangeTimecodeFormat = NSNotification.Name("did-change-timecode-format")
}
