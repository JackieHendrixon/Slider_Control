//
//  Keyframe.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation

class Keyframe: NSObject{

    static var parametersRange: Range = Range(min: Parameters(x: 0, pan: 0, tilt: 0), max: Parameters(x: 100, pan: 360, tilt: 90)) 
    
    var timecode: Timecode = Timecode(frames: 0)
    
    var parameters: Parameters = Parameters(x:0, pan:0, tilt:0)
    
    init(timecode: Timecode, parameters: Parameters) {
        self.timecode = timecode
        self.parameters = parameters
    }
}

struct Range {
    var min: Parameters
    var max: Parameters
}
