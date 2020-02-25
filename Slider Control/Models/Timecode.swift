//
//  Timecode.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation



// A model of timecode. Static part is used to hold current timecode. Also provides a timer.
class Timecode: NSObject {
    static func == (lhs: Timecode, rhs: Timecode) -> Bool {
        return lhs.totalFrames == rhs.totalFrames
    }
    
    static var FPS: Int = 24
    static var fullFormat = true {
        didSet {
            NotificationCenter.default.post(name: .didChangeTimecodeFormat, object: nil)
        }
    }

    // MARK: - Properties
    
    var frame: Int = 0
    var sec: Int = 0
    var min: Int = 0
    
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
    
    init(min: Int, sec: Int, frame: Int) {
        guard min >= 0 else {return}
        guard sec >= 0 && sec < 60 else {return}
        guard frame >= 0 && frame < Timecode.FPS else {return}
        
        self.min = min
        self.sec = sec
        self.frame = frame
    }
    
    init(frames: Int) {
        self.min = frames/Timecode.FPS/60
        self.sec = frames/Timecode.FPS%60
        self.frame = frames%Timecode.FPS
    } 
}

extension NSNotification.Name {
    static let didChangeTimecodeFormat = NSNotification.Name("did-change-timecode-format")
}

// Protocol for updating timecode label
protocol GlobalTimecodeDelegate {
    func didUpdateGlobalTimecode()
}

class GlobalTimecode {
    static var current: Timecode = Timecode(frames: 0){
        didSet{

            for delegate in delegates {
                delegate.didUpdateGlobalTimecode()
            }

        }
    }
    
    static var delegates = [GlobalTimecodeDelegate]()
    
    static private var timer = Timer()
    
    static var isRunning:Bool = false
    
    static func run(){
        timer = Timer.scheduledTimer(timeInterval: 1.0/Double(Timecode.FPS), target: self, selector: #selector(GlobalTimecode.nextFrame), userInfo: nil, repeats: true)
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
