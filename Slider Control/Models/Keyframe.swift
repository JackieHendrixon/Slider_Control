//
//  Keyframe.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation

class Keyframe: NSObject {

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

enum ValueType {
    case pan, tilt, slide
}

class NewKeyframe {
    static let panMax: Float = 360
    static let panMin: Float = 0
    static let tiltMax: Float = 90
    static let tiltMin: Float = 0
    static let slideMax: Float = 100
    static let slideMin: Float = 0
    static func == (lhs: NewKeyframe, rhs: NewKeyframe) -> Bool {
        var result = lhs.timecode == rhs.timecode && lhs.value == rhs.value
        if let l = lhs.leftSlope, let r = rhs.leftSlope {
            result = result && l == r
        }
        if let l = lhs.rightSlope, let r = rhs.rightSlope {
            result = result && l == r
        }
        
        return result
        
    }
    
    static func != (lhs: NewKeyframe, rhs: NewKeyframe) -> Bool {
        var result = lhs.timecode != rhs.timecode || lhs.value != rhs.value
        if let l = lhs.leftSlope, let r = rhs.leftSlope {
            result = result || l != r
        }
        if let l = lhs.rightSlope, let r = rhs.rightSlope {
            result = result || l != r
        }
        
        return result
        
    }
    
    var rightSlope: Point?
    var leftSlope: Point?
    
    var type: ValueType
    
    var timecode: Timecode
    
    var value: Float = 0 {
        willSet{
            let min: Float!
            let max: Float!
            switch type {
            case .pan:
                min = NewKeyframe.panMin
                max = NewKeyframe.panMax
            case .tilt:
                min = NewKeyframe.tiltMin
                max = NewKeyframe.tiltMax
            case .slide:
                min = NewKeyframe.slideMin
                max = NewKeyframe.slideMax
            }
            guard newValue >= min, newValue <= max
                else {
                    fatalError("Fatal error: Attempted to set forbidden value for Keyframe.value")
            }
        }
    }
    
    init(timecode: Timecode, value: Float, type: ValueType, leftSlope: Point? = nil, rightSlope: Point? = nil) {
        self.type = type
        self.timecode = timecode
        self.value = value
        self.leftSlope = leftSlope
        self.rightSlope = rightSlope
    }
}


