//
//  Extensions.swift
//  Slider Control
//
//  Created by Franek on 30/03/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let appOrange: UIColor = UIColor(red: 254/255, green: 173/255, blue: 75/255, alpha: 1)
    
}


extension UIView {
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        } else {
            return self.rightAnchor
        }
    }
    
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        } else {
            return self.leftAnchor
        }
    }
    
    var safeAreaLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
        }
    }
    
    var safeAreaTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        } else {
            return self.trailingAnchor
        }
    }
}

@nonobjc extension UIViewController {
    //    func add(_ child: UIViewController, frame: CGRect? = nil) {
    //        addChild(child)
    //
    //        if let frame = frame {
    //            child.view.frame = frame
    //        }
    //
    //        view.addSubview(child.view)
    //        child.didMove(toParent: self)
    //    }
    //
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension CGRect {
    var center: CGPoint {
        get{
            return CGPoint(x: self.midX, y: self.midY)
        }
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        var rhs = rhs
        if rhs == 0 {
            rhs = CGFloat.leastNonzeroMagnitude
        }
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }
    
    static func /=(lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    static func *=(lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        let x = (self.x - point.x)
        let y = (self.y - point.y)
        
        return (x*x + y*y).squareRoot()
    }
    
    func pointAtLine(to point: CGPoint, distance: CGFloat) -> CGPoint {
        let direction = (point - self) / self.distance(from: point)
        return self + direction * distance
    }
    
    func angle(with point: CGPoint) -> CGFloat {
        let vector = point - self
        
        if vector.x >= 0 {
            return atan(vector.y / vector.x)
        } else {
            return atan(vector.y / vector.x) + CGFloat.pi
        }
    }
    
    
}

struct Point {
    static func == (lhs: Point, rhs: Point) -> Bool {
         return lhs.x == rhs.x && lhs.y == rhs.y
    }
    static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func /(lhs: Point, rhs: Float) -> Point {
        var rhs = rhs
        if rhs == 0 {
            rhs = Float.leastNonzeroMagnitude
        }
        return Point(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func *(lhs: Point, rhs: Float) -> Point {
        return Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func +=(lhs: inout Point, rhs: Point) {
        lhs = lhs + rhs
    }
    
    static func -=(lhs: inout Point, rhs: Point) {
        lhs = lhs - rhs
    }
    
    var x: Float
    var y: Float
}
