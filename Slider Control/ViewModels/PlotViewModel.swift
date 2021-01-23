//
//  PlotViewModel.swift
//  Slider Control
//
//  Created by Franek on 09/06/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import Foundation
import UIKit

class PlotsViewModel {
    var sequence: NewSequenceModel
    
    weak var delegate: PlotsViewModelDelegate?
    
    @objc func didUpdateModel(){
        delegate?.didViewModelUpdate()
    }
    
    init(sequence: NewSequenceModel) {
        self.sequence =  sequence
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateModel), name: .didUpdateSequence , object: nil)
    }
    

}

extension PlotsViewModel{
    func configure(_ view: NewPlotView, ofType: ValueType) {
        
        view.points.forEach{view.deletePoint($0)}
        
        let keyframes: Keyframes!
        switch ofType {
        case .pan:
            keyframes = sequence.panKeyframes
            view.gridLayer.max.y = 360
        case .tilt:
            keyframes = sequence.tiltKeyframes
            view.gridLayer.max.y = 90
        case .slide:
            keyframes = sequence.slideKeyframes
            view.gridLayer.max.y = 100
        }
        view.gridLayer.setup()
        
        view.setNeedsDisplay()
        
        
        let maxValue = CGFloat(view.gridLayer.max.y)
        let maxFrame = CGFloat(view.gridLayer.max.x)
        
        let width = view.bounds.width
        let height = view.bounds.height
        
        for keyframe in keyframes.array {
            let frame = CGFloat(keyframe.timecode.totalFrames)
            let value = CGFloat(keyframe.value)
            let x = (frame / maxFrame) * width
            
            let y = height - (value / maxValue) * height
            
            let point = BezierPathPointView(.init(x: x, y: y))
            if let leftSlope = keyframe.leftSlope {
                let x = x + CGFloat(leftSlope.x) / maxFrame * width
                let y = y - CGFloat(leftSlope.y) / maxValue * height
                let controlPoint = ControlPointView(.init(x: x, y: y), for: point)
                point.controlPoint1 = controlPoint
            }
            
            if let rightSlope = keyframe.rightSlope {
                let x = x + CGFloat(rightSlope.x) / maxFrame * width
                let y = y - CGFloat(rightSlope.y) / maxValue * height
                let controlPoint = ControlPointView(.init(x: x, y: y), for: point)
                point.controlPoint2 = controlPoint
            }
            view.addPoint(point)
            
        }
    }
}

protocol PlotsViewModelDelegate: AnyObject {
    func didViewModelUpdate()
}
