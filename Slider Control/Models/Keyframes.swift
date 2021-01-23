//
//  Keyframes.swift
//  Slider Control
//
//  Created by Franek on 09/06/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import Foundation



class Keyframes {
    static func testKeyframes(type: ValueType) -> Keyframes {
        let keyframes = Keyframes(type: type)
        keyframes.insertRaw(keyframes: [NewKeyframe(timecode: Timecode(frames: 10), value: 50, type: type, rightSlope: Point(x: 10, y: 0) ),
                                     NewKeyframe(timecode: Timecode(frames: 50), value: 50, type: type, leftSlope: Point(x: -15, y: 0), rightSlope: Point(x: 30, y: 0)),
                                     NewKeyframe(timecode: Timecode(frames: 250), value: 90, type: type, leftSlope: Point(x: -20, y: 0))])
        return keyframes
    }
    
    private let type: ValueType
    
    var array: [NewKeyframe] = [] {
        didSet{
            printArray()
        }
    }
    
    func printArray(){
        print(" ---Array items: ")
        for keyframe in array {
            print("\t")
            print("\ttype: \(keyframe.type)")
            print("\tvalue: \(keyframe.value)")
            print("\ttimecode: \(keyframe.timecode.totalFrames)")
            print("\tleftSlope: \(keyframe.leftSlope)")
            print("\trightSlope: \(keyframe.rightSlope)")
            print (".")
        }
    }


    init(type: ValueType) {
        self.type = type
    }
    
    func insertValid(point: Point) {
        let frame = Int(point.x)
        let keyframe = NewKeyframe(timecode: Timecode(frames: frame), value: point.y, type: self.type)
        if let leftNeighbour = array.last(where: {$0.timecode.totalFrames < frame}) {
            keyframe.leftSlope = .init(x: -20, y: 0)
            if let last = array.last, leftNeighbour == last {
                last.rightSlope = .init(x: 20, y: 0)
            }
        } 
        
        if let rightNeighbour = array.first(where: {$0.timecode.totalFrames > frame})  {
            keyframe.rightSlope = .init(x: 20, y: 0)
            if let first = array.first, rightNeighbour == first {
                first.leftSlope = .init(x: -20, y: 0)
            }
        }
        insertRaw(keyframe: keyframe)
        
        
    }
    
    func insertRaw(keyframe: NewKeyframe) {
        
        guard keyframe.type == self.type else {
            fatalError("Fatal error: Attempted to insert keyframe of wrong type")
        }
        
        array = array.filter{$0.timecode != keyframe.timecode}
        array.append(keyframe)
        
        array.sort{ $0.timecode < $1.timecode}
    }
    
    func insertRaw(keyframes: [NewKeyframe]){
        for keyframe in keyframes {
            insertRaw(keyframe: keyframe)
        }
    }
    
    func delete(point: Point) {
        let frame = Int(point.x)
        let value = point.y
        
        array = array.filter {$0.timecode.totalFrames != frame && $0.value != value}
    }
    
    func deleteKeyframe(with timecode: Timecode) {
        deleteKeyframe(with: timecode.totalFrames)
    }
    
    func deleteKeyframe(with frame: Int) {
        array = array.filter{$0.timecode.totalFrames != frame}
    }
    
    func deleteKeyframe(_ keyframe: NewKeyframe){
        array = array.filter{$0 != keyframe}
    }
    
    func move(point: Point, to newPoint: Point){
        let frame = Int(point.x)
        let value = point.y
        
        
        
        if let first = array.first(where: {$0.timecode.totalFrames == frame }) {
            
            deleteKeyframe(first)
            let new = NewKeyframe(timecode: Timecode(frames: Int(newPoint.x)), value: newPoint.y, type: type, leftSlope: first.leftSlope, rightSlope: first.rightSlope)
            insertRaw(keyframe: new)
        }
        
    }
    
    func moveControlPoint(old: Point, new: Point, parent: Point, second: Point?){
        let frame = Int(parent.x)
        let value = parent.y
        
        print(old,new,parent)
        
        if let first = array.first(where: {$0.timecode.totalFrames == frame && $0.value == value}) {
            if let leftSlope = first.leftSlope, leftSlope == old {
                first.leftSlope = new
                if let second = second {
                    first.rightSlope = second
                }
            } else if let rightSlope = first.rightSlope, rightSlope == old {
                first.rightSlope = new
                if let second = second {
                    first.leftSlope = second
                }
            }
        }
    }
    
    
    func value(for timecode: Timecode) -> Float{
        var value: Float = 0
        let frame = timecode.totalFrames
        print("Value for frame: \(frame)")
        printArray()
        
        if let exact = array.first(where: {$0.timecode.totalFrames == frame}) {
            value = exact.value
            print("exact value:  \(exact.value)")
            
        } else if let c0 = array.last(where: {$0.timecode.totalFrames < frame}), let c3 = array.first(where: {$0.timecode.totalFrames > frame }), let c1 = c0.rightSlope, let c2 = c3.leftSlope {
            let c0 = Point(x: Float(c0.timecode.totalFrames), y: c0.value)
            let c3 = Point(x: Float(c3.timecode.totalFrames), y: c3.value)
            value = Math.calcuatePointsOnBezierCurve(for: Float(frame), c0: c0, c1: c1+c0, c2: c2+c3, c3: c3)[0].y
        } else if let first = array.first(where: {$0.timecode.totalFrames > frame}){
            value = first.value
        } else if let last = array.last(where: {$0.timecode.totalFrames < frame}){
            value = last.value
        } 
        print(value)
        return value
    }
    
}
