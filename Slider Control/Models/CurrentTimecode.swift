//
//  GlobalTimecode.swift
//  Slider Control
//
//  Created by Franek on 28/03/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import Foundation



class CurrentTimecode {
    static var current: Timecode = Timecode(frames: 0){
        didSet{
            NotificationCenter.default.post(name: .didUpdateCurrentTimecode, object: nil)
        }
    }
    
    static var timecodeInterval = 1.0 {
        didSet{
            NotificationCenter.default.post(name: .didUpdateTimelapseInterval, object: nil)
        }
    }
    
    static private var timer = Timer()
    
    static var isRunning:Bool = false
    
    static func run(){
        timer = Timer.scheduledTimer(timeInterval: timecodeInterval, target: self, selector: #selector(CurrentTimecode.nextFrame), userInfo: nil, repeats: true)
        isRunning = true
    }
    
    static func pause() {
        timer.invalidate()
        isRunning = false
    }
    
    @objc static func nextFrame(){
        if let lastFrame = Sequence.instance.keyframes?.last?.timecode.totalFrames{
            if current.totalFrames < lastFrame {
                current = Timecode(frames: current.totalFrames + 1)
            } else {
                pause()
            }
        } else {
            pause()
        }
        
    }
    
    static func previousFrame(){
        if(current.totalFrames - 1) >= 0 {
            current = Timecode(frames: current.totalFrames - 1)
        }
    }
    
    static func stop(){
        reset()
        pause()
    }
    
    static func reset() {
        current = Timecode(frames: 0)
    }
}

extension NSNotification.Name {
    static let didUpdateCurrentTimecode = NSNotification.Name("did-update-current-timecode")
    
    static let didUpdateTimelapseInterval = NSNotification.Name("did-update-timelapse-interval")
}


