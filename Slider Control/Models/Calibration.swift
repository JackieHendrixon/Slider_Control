//
//  CalibrationInfo.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation

// Structure that is filled with calibration information

struct Calibration {
    var deviceStepsRange: Parameters
    var appValueRange: Parameters
    
    func convertValueToSteps(value: Parameters) -> Parameters{
        let x = value.x * deviceStepsRange.x / appValueRange.x
        let pan = value.pan * deviceStepsRange.pan / appValueRange.pan
        let tilt = value.tilt * deviceStepsRange.tilt / appValueRange.tilt
        
        return Parameters(x: x, pan: pan, tilt: tilt)
    }
    
    func convertStepsToValue(steps: Parameters) -> Parameters{
        let x = steps.x *  appValueRange.x / deviceStepsRange.x
        let pan = steps.pan * appValueRange.pan / deviceStepsRange.pan
        let tilt = steps.tilt * appValueRange.tilt / deviceStepsRange.tilt
        
        return Parameters(x: x, pan: pan, tilt: tilt)
    }
}
