//
//  Sequence.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation

protocol SequenceDelegate{
    func didUpdate()
}

class Sequence{
    
    static let instance = Sequence()
    
    var keyframes: [Keyframe]? = [Keyframe(timecode: Timecode(frames: 0),parameters: Parameters( x: 0, pan: 0, tilt: 0)),
                                  Keyframe(timecode: Timecode(frames: 101), parameters: Parameters( x: 100, pan: 90, tilt: 0)),
                                  Keyframe(timecode: Timecode(frames: 504), parameters: Parameters( x: 0, pan: 7, tilt: 90))] {
        didSet {
            for delegate in delegates {
                delegate.didUpdate()
            }
            //NotificationCenter.default.post(name: .didUpdateSequence, object: nil)
        }
    }
    
    var delegates = [SequenceDelegate]()
    
    func calculateParameters(for timecode: Timecode) -> Parameters{
      
        
        if let lower = keyframes?.last(where: {$0.timecode.totalFrames <= timecode.totalFrames}), let higher = keyframes?.first(where: {$0.timecode.totalFrames >= timecode.totalFrames}){
                if higher == lower {
                    return lower.parameters
                }
            
                
                let multiplier = Float(timecode.totalFrames - lower.timecode.totalFrames) / Float(higher.timecode.totalFrames - lower.timecode.totalFrames)
                let x = lower.parameters.x + (higher.parameters.x-lower.parameters.x)  * multiplier
                let pan = lower.parameters.pan + (higher.parameters.pan - lower.parameters.pan)  * multiplier
                let tilt = lower.parameters.tilt + (higher.parameters.tilt - lower.parameters.tilt)  * multiplier

                return Parameters(x: x, pan: pan, tilt: tilt)
        }
        if let  last = keyframes?.last {
            return last.parameters
        }
        return Parameters(x:0,pan:0,tilt:0)
    }
    
    func sort(){
         self.keyframes?.sort(by: {$0.timecode.totalFrames < $1.timecode.totalFrames})
    }
    
}

extension NSNotification.Name {
    static let didUpdateSequence = NSNotification.Name("did-update-sequence")
}
