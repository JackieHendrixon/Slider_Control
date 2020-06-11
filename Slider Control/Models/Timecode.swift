//
//  Timecode.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation

// TimecodeModel
class Timecode: NSObject {
    static func == (lhs: Timecode, rhs: Timecode) -> Bool {
        return lhs.totalFrames == rhs.totalFrames
    }
    
    static func > (lhs: Timecode, rhs: Timecode) -> Bool {
        return lhs.totalFrames > rhs.totalFrames
    }
    
    static func < (lhs: Timecode, rhs: Timecode) -> Bool {
        return lhs.totalFrames < rhs.totalFrames
    }
    
    static var FPS: Int = 24
    static var fullFormat = true {
        didSet {
            NotificationCenter.default.post(name: .didChangeTimecodeFormat, object: nil)
        }
    }

    // MARK: - Properties
    
    var frame: Int {
        willSet {
            guard newValue >= 0, newValue < Timecode.FPS
                else {
                    fatalError("Fatal error: Attempt to set forbidden value for Timecode.frame")
            }
        }
    }
    
    var sec: Int {
        willSet {
            guard newValue >= 0, newValue < 60 else { fatalError("Fatal error: Attempt to set forbidden value for Timecode.sec")}
        }
    }
    var min: Int {
        willSet {
            guard newValue >= 0, newValue < 60 else { fatalError("Fatal error: Attempt to set forbidden value for Timecode.min")}
        }
    }
    
    var totalFrames: Int {
        return ((min*60)+sec)*Timecode.FPS + frame
    }
    
    var toString: String{
        if Timecode.fullFormat {
        return String(format: "%02d", min ) + ":"
            + String(format: "%02d", sec) + ":"
            + String(format: "%02d", frame)
        } else {
            return String(format: "%03d", totalFrames)
        }
    }
    
    // MARK: - Init
    
    init(min: Int = 0, sec: Int = 0, frame: Int = 0) {
        
        self.min = min
        self.sec = sec
        self.frame = frame
    }
    
    init(frames: Int) {
        self.min = frames/Timecode.FPS / 60
        self.sec = frames/Timecode.FPS % 60
        self.frame = frames%Timecode.FPS
    } 
}


