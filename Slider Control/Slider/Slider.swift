//
//  Slider.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation

//enum SliderMode: {
//    case live
//    case sequence
//}

class SliderID{
    static var service = "FFE0"
    static var characteristic = "FFE1"
    static var deviceName = "MSF Slider"
}

enum SliderCommandSign: String{
    case isReady = "?"
    case getCalibration = "@"
    case getCurrentPosition = "#"
    case sequenceMode = "^"
    case liveMode = "*"
    case x = "s"
    case pan = "p"
    case tilt = "t"
    case end = " "
}

enum  SliderMode {
    case live, sequence
}

class Slider: NSObject {
    // MARK: Properties
    
    var delegates = [SliderDelegate]()
    var mode: SliderMode = .live {
        didSet {
            NotificationCenter.default.post(name: .didSwitchMode, object: nil)
        }
    }
    
    var isConnected: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .didUpdateConnection, object: nil)
        }
    }
    
    var isOnline: Bool = false
    
    var calibration: Calibration?
    
    var feedback: String?
    
    var currentSpeed: Parameters = Parameters(x:0, pan:0, tilt:0) {
        didSet {
            for delegate in delegates {
                delegate.didUpdateSpeed()
            }
        }
    }
    
    var currentPosition: Parameters = Parameters(x:50, pan:0, tilt:0){
        didSet {
            for delegate in delegates {
                delegate.didUpdatePosition()
            }
        }
    }
    
    var maxGears: Int = 3
    
}

protocol SliderDelegate {
    func didUpdateSpeed()
    
    func didUpdatePosition()
}


extension NSNotification.Name {
    static let didSwitchMode = NSNotification.Name("did-switch-mode")
    
    static let didUpdateConnection = NSNotification.Name("did-update-connection")
}
