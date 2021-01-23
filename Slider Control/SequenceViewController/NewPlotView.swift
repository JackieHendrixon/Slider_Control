//
//  NewPlot.swift
//  Slider Control
//
//  Created by Franek on 08/06/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import Foundation
import UIKit

class PlotSettings {
    static var plotLineColor: CGColor = UIColor.appOrange.cgColor
    static var plotLineWidth: CGFloat = 10
    
    static var plotPointColor: CGColor = UIColor.black.cgColor
    static var plotPointSize: CGFloat = 20
    
    static var indicatorWidth: CGFloat = 20
    static var indicatorColor: CGColor = UIColor.black.cgColor
    
    static var gridHorizontalLineWidth: CGFloat = 2
    static var gridHorizontalLineColor: CGColor = UIColor.gray.cgColor
    static var gridMaxHorizontalLines: CGFloat = 10
    
    static var gridVerticalLineWidth: CGFloat = 2
    static var gridVerticalLineColor: CGColor = UIColor.gray.cgColor
    static var gridMaxVerticalLines: CGFloat = 20
    
    static var textSize: CGFloat = 10
    static var textColor: CGColor = UIColor.white.cgColor
}

protocol PlotViewDelegate: AnyObject {
    func addedPoint(_ point: Point, for view: NewPlotView)
    
    func deletedPoint(_ point: Point, for view: NewPlotView)
    
    func movedPoint(from oldPoint: Point, to newPoint: Point, for view: NewPlotView)
    
    func movedControlPoint(from oldPoint: Point, to newPoint: Point, parent: Point, secondPoint: Point?, for view: NewPlotView)
}

class NewPlotView: UIView {
    var points = [BezierPathPointView]()
    
    var plotPathLayer = CAShapeLayer()
    
    var drawableArea: CGRect {
        let inset:CGFloat = 0
        return bounds.inset(by: UIEdgeInsets(top: inset,
                                            left: inset,
                                            bottom: inset,
                                            right: inset) )
    }
    
    var gridLayer: GridLayer!
    
    var selectedPoint: PointView?
    var selectedPointOldPosition: CGPoint?
    
//
//    weak var selectedPoint: BezierPathPointView? {
//        willSet {
//            if let newValue = newValue {
//                newValue.isSelected = true
//
//            }
//            if let selectedPoint = selectedPoint {
//                selectedPoint.isSelected = false
//            }
//        }
//    }
    
    weak var delegate: PlotViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = .clear
        
        self.gridLayer = GridLayer(frame: self.bounds, max: .init(x: 300, y: 100))
        self.layer.addSublayer(self.gridLayer)
        
//        let drawableView = UIView(frame: drawableArea)
//        drawableView.layer.borderColor = UIColor.black.cgColor
//        drawableView.layer.borderWidth = 2
//        self.addSubview(drawableView)
        
        
        plotPathLayer.fillColor = UIColor.clear.cgColor
        plotPathLayer.strokeColor = UIColor.orange.cgColor
        plotPathLayer.lineWidth = 4.0
        self.layer.addSublayer(plotPathLayer)
        
        setupGestureRecognizers()
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
        guard points.count>1 else {
            plotPathLayer.path = nil
            return
        }
        
        let plotPath = UIBezierPath()
        plotPath.move(to: points[0].center)
        
        for i in 1...points.count-1 {
            if let controlPoint1 = points[i-1].controlPoint2, let controlPoint2 = points[i].controlPoint1 {
                plotPath.addCurve(to: points[i].center, controlPoint1: controlPoint1.center, controlPoint2: controlPoint2.center)
            }
        }
        plotPathLayer.path = plotPath.cgPath
    }
    
  
    
    func addNewPoint(_ point: BezierPathPointView) {
        guard !points.contains(point) else { return }
        
        if let i = points.firstIndex(where: {$0.center.x > point.center.x}) {
            points.insert(point, at: i)
        } else  {
            points.append(point)
        }
        
        let i = points.firstIndex(of: point)!
        
        switch points.count {
        case 1:
            break
        case 2:
            points[0].controlPoint2 = ControlPointView.inDirection(of: points[1], for: points[0])
            self.addSubview(points[0].controlPoint2!)
            points[1].controlPoint1 = ControlPointView.inDirection(of: points[0], for: points[1])
            self.addSubview(points[1].controlPoint1!)
            
        default:
            if point == points.first {
                point.controlPoint2 = ControlPointView.inDirection(of: points[1], for: point)
                self.addSubview(point.controlPoint2!)
                ControlPointView.smoothBetween(previous: point, next: points[i+2], for: &points[i+1])
                self.addSubview(points[i+1].controlPoint1!)
                self.addSubview(points[i+1].controlPoint2!)
                
            } else if point == points.last {
                point.controlPoint1 = ControlPointView.inDirection(of: points[points.count-2], for: point)
                self.addSubview(point.controlPoint1!)
                ControlPointView.smoothBetween(previous: points[i-2], next: point, for: &points[i-1])
                self.addSubview(points[i-1].controlPoint1!)
                self.addSubview( points[i-1].controlPoint2!)
            } else {
                ControlPointView.smoothBetween(previous: points[i-1], next: points[i+1], for: &points[i])
                
                //self.addPointsBetween(points[i-1], points[i])
                
                self.addSubview(point.controlPoint1!)
                self.addSubview(point.controlPoint2!)
            }
        }
        
        self.addSubview(point)
        self.setNeedsDisplay()
    }
    
    
    
    func addPoint(_ point: BezierPathPointView) {
        
        points.append(point)
        self.addSubview(point)
        if let controlPoint1 = point.controlPoint1 {
            self.addSubview(controlPoint1)
        }
        if let controlPoint2 = point.controlPoint2 {
            self.addSubview(controlPoint2)
        }
    }
    
    func movePoint(_ point: BezierPathPointView, to destination: CGPoint) {
        
        let validatedDestination = validate(position: destination, for: point)
        point.moveTo(validatedDestination)
        
        self.setNeedsDisplay()
    }
    
    func movePoint(_ controlPoint: ControlPointView, to destination: CGPoint) {
        
        let validatedDestination = validate(position: destination, for: controlPoint)
        controlPoint.moveTo(validatedDestination)
        
        updateSecondControlPoint(for: controlPoint)
        
        self.setNeedsDisplay()
    }
    
    func deletePoint(_ point: BezierPathPointView) {
        guard points.contains(point) else { return }
        
        switch points.count {
        case 1:
            break
        case 2:
            if point != points.first {
                points[0].controlPoint2 = nil
            } else {
                points[1].controlPoint1 = nil
            }
            
        default:
            if point == points.last {
                points[points.count-2].controlPoint2 = nil
                point.controlPoint1 = nil
            } else if point == points.first {
                points[1].controlPoint1 = nil
                points[1].controlPoint1 = nil
                point.controlPoint2 = nil
            }
        }
        
        point.controlPoint1 = nil
        point.controlPoint2 = nil
        
        points = points.filter({$0 !== point})
        
        point.removeFromSuperview()
        self.setNeedsDisplay()
    }
    
    private func validate(position: CGPoint, for point: BezierPathPointView) -> CGPoint {
        let i = points.firstIndex(of: point)!
        
        var validatedPosition = position
        
        if i > 0 {
            let previous = points[i-1]
            let limit = previous.center.x + BezierPathPointView.radius*2
            if position.x < limit  {
                validatedPosition.x = limit
            }
            
            if let c1 = previous.controlPoint2?.center, let controlPointRelativePosition = point.controlPoint1?.relativePosition  {
                let c0 = previous.center
                let c2 = position + controlPointRelativePosition
                let c3 = position
                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3) {
                    let c3 = point.center
                    while !Math.isSingleValuedBezier(c0: c0, c1: previous.controlPoint2!.reduce(1),
                                                     c2: point.controlPoint1!.reduce(1),
                                                     c3: c3) {
                                                        if controlPointRelativePosition.x == 0 && controlPointRelativePosition.y == 0 {
                                                            break
                                                        }
                    }
                }
            }
            
            
        }
        
        if i < points.count-1 {
            let next = points[i+1]
            let limit = next.center.x - BezierPathPointView.radius*2
            if position.x > limit  {
                validatedPosition.x = limit
            }
            
            if let c2 = next.controlPoint1?.center, let controlPointRelativePosition = point.controlPoint2?.relativePosition {
                let c0 = position
                let c1 = position + controlPointRelativePosition
                let c3 = next.center
                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3) {
                    let c0 = point.center
                    while !Math.isSingleValuedBezier(c0: c0, c1: point.controlPoint2!.reduce(1),
                                                     c2: next.controlPoint1!.reduce(1),
                                                     c3: c3) {
                                                        if controlPointRelativePosition.x == 0 && controlPointRelativePosition.y == 0 {
                                                            break
                                                        }
                    }
                }
            }
        }
        
        if let controlPoint1 = point.controlPoint1 {
            controlPoint1.moveTo(validatedPosition + controlPoint1.relativePosition)
        }
        
        if let controlPoint2 = point.controlPoint2 {
            controlPoint2.moveTo(validatedPosition + controlPoint2.relativePosition)
        }
        
        return validatedPosition
        
    }
    
    private func validate(position: CGPoint, for controlPoint: ControlPointView) -> CGPoint {
        var validatedPosition = position
        
        if controlPoint === controlPoint.parent.controlPoint1 {
            if position.x >= controlPoint.parent.center.x {
                validatedPosition.x = controlPoint.parent.center.x - 1
            }
        } else {
            if position.x <= controlPoint.parent.center.x {
                validatedPosition.x = controlPoint.parent.center.x + 1
            }
        }
        
        let minDistanceFromParent:CGFloat = BezierPathPointView.radius + ControlPointView.radius
        if validatedPosition.distance(from: controlPoint.parent.center) < minDistanceFromParent {
            let y = validatedPosition.y - controlPoint.parent.center.y
            
            if controlPoint === controlPoint.parent.controlPoint1 {
                validatedPosition.x = controlPoint.parent.center.x - (minDistanceFromParent*minDistanceFromParent-y*y).squareRoot()
            } else {
                validatedPosition.x = controlPoint.parent.center.x + (minDistanceFromParent*minDistanceFromParent-y*y).squareRoot()
            }
        }
        
        let i = points.firstIndex(of: controlPoint.parent)!
        
        if i > 0, controlPoint === controlPoint.parent.controlPoint1 {
            
            
            if let c1 = points[i-1].controlPoint2?.center {
                let c0 = points[i-1].center
                let c2 = validatedPosition
                let c3 = controlPoint.parent.center
                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3 ) {
                    validatedPosition.x = controlPoint.center.x
                }
            }
        }
        
        if i < points.count - 1, controlPoint === controlPoint.parent.controlPoint2 {
            if let c2 = points[i+1].controlPoint1?.center {
                let c0 = controlPoint.parent.center
                let c1 = validatedPosition
                let c3 = points[i+1].center
                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3 ) {
                    validatedPosition.x = controlPoint.center.x
                }
            }
        }
        
        return validatedPosition
    }
    
    private func updateSecondControlPoint(for controlPoint: ControlPointView) {
        var secondControlPoint: ControlPointView?
        
        if controlPoint === controlPoint.parent.controlPoint1 {
            secondControlPoint = controlPoint.parent.controlPoint2
        } else {
            secondControlPoint = controlPoint.parent.controlPoint1
        }
        
        if let secondControlPoint = secondControlPoint {
            let distance = secondControlPoint.center.distance(from: controlPoint.parent.center)
            let newPosition = controlPoint.parent.center.pointAtLine(to: controlPoint.center, distance: -distance)
            secondControlPoint.moveTo(newPosition)
        }
    }
    
    private func addPointsBetween(_ point1: BezierPathPointView, _ point2: BezierPathPointView) {
        let points = calculatePointBetween(point1,point2)
        for point in points {
            let point = PointView(point)
            point.backgroundColor = .red
            self.addSubview(point)
        }
    }
    
    private func calculatePointBetween(_ point1: BezierPathPointView, _ point2: BezierPathPointView) -> [CGPoint] {
        var result = [CGPoint]()
        
        let c0 = point1.center
        let c3 = point2.center
        let x = c0.x + 20
        if let c1 = point1.controlPoint2?.center, let c2 = point2.controlPoint1?.center {
            result = Math.calcuatePointsOnBezierCurve(for: x, c0: c0, c1: c1, c2: c2, c3: c3)
        }
        return result
    }
    
    
    //MARK: Gesture Recognizers
    
    private func setupGestureRecognizers() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGestureRecognizer)
        
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    @objc func didSingleTap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self)
        
        if let selectedPoint = self.hitTest(location, with: nil) as? PointView {
            if let point = selectedPoint as? BezierPathPointView {
                self.selectedPoint = point
            }
            
        } else {
            if self.selectedPoint == nil {
                if self.drawableArea.contains(location) {
//                    let point = BezierPathPointView(location)
//                    self.addNewPoint(point)
                    let maxFrame = self.gridLayer.max.x
                    let maxValue = self.gridLayer.max.y
                    
                    let width = Float(self.bounds.width)
                    let height = Float(self.bounds.height)
                    
                    let x = (Float(location.x) / width * maxFrame).rounded()
                    let y = ((height - Float( location.y)) / height * maxValue).rounded()
                    
                    self.delegate?.addedPoint(Point(x: x, y: y), for: self)
                    
                }
                
            } else {
                self.selectedPoint = nil
            }
        }
    }
    
    @objc func didDoubleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        
        if let selectedPoint = self.hitTest(location, with: nil) as? BezierPathPointView {
//            self.deletePoint(selectedPoint)
            let maxFrame = self.gridLayer.max.x
            let maxValue = self.gridLayer.max.y
            
            let width = Float(self.bounds.width)
            let height = Float(self.bounds.height)
            
            let x = (Float(selectedPoint.center.x) / width * maxFrame).rounded()
            let y = ((height - Float(selectedPoint.center.y)) / height * maxValue).rounded()
            
            self.delegate?.deletedPoint(Point(x: x, y: y), for: self)
            
        } else {
            
        }
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        var location = sender.location(in: self)
        
        print("locatioin: \(location)")
        
        if sender.state == .began {
            if let selectedPoint = self.hitTest(location, with: nil) as? PointView {
                self.selectedPoint = selectedPoint
                self.selectedPointOldPosition = selectedPoint.center
            }
        } else if sender.state == .changed  {
            
            if let selectedPoint = self.selectedPoint {
                
                if !self.drawableArea.contains(location) {
                    if location.x > self.drawableArea.maxX {
                        location.x = self.drawableArea.maxX
                    }
                    if location.x < self.drawableArea.minX {
                        location.x = self.drawableArea.minX
                    }
                    if location.y > self.drawableArea.maxY {
                        location.y = self.drawableArea.maxY
                    }
                    if location.y < self.drawableArea.minY {
                        location.y = self.drawableArea.minY
                    }
                }
                if let controlPoint = selectedPoint as? ControlPointView {
                    
                    self.movePoint(controlPoint, to: location)
                } else if let selectedPoint = selectedPoint as? BezierPathPointView {
                    self.movePoint(selectedPoint, to: location)
                  
                    
                    
                }
                
            } else {
                
            }
            
        } else if sender.state == .ended {
            
            
            if let selectedPoint = self.selectedPoint , let oldPosition = selectedPointOldPosition{
                
                let oldPoint = convert(cgPoint: oldPosition)
                
                let newPoint = convert(cgPoint: location)
                
                if let controlPoint = selectedPoint as? ControlPointView {
                    
                    let parentPoint = convert(cgPoint: controlPoint.parent.center)
                    
                    let secondControlPoint: ControlPointView?
                    if controlPoint === controlPoint.parent.controlPoint1 {
                        secondControlPoint = controlPoint.parent.controlPoint2
                    } else {
                        secondControlPoint = controlPoint.parent.controlPoint1
                    }
                    
                    var secondPoint: Point? = nil
                    if let secondControlPoint = secondControlPoint {
                        secondPoint = convert(cgPoint: secondControlPoint.center) - parentPoint
                    }
                    
                    
                    
                    self.delegate?.movedControlPoint(from: oldPoint-parentPoint, to: newPoint-parentPoint, parent: parentPoint, secondPoint: secondPoint , for: self)
                } else if let selectedPoint = selectedPoint as? BezierPathPointView {
                    
                    
                    
                    self.delegate?.movedPoint(from: oldPoint, to: newPoint, for: self)
                }
                    
                
                
            }
            self.selectedPoint = nil
            self.selectedPointOldPosition = nil
        }
    }
    
    //MARK:
//    func convert(point: Point) -> CGPoint {
//        return _
//    }
    
    func convert(cgPoint: CGPoint) -> Point {
        let maxFrame = self.gridLayer.max.x
        let maxValue = self.gridLayer.max.y
        
        let width = Float(self.bounds.width)
        let height = Float(self.bounds.height)
        
        let x = max(min((Float(cgPoint.x) * maxFrame / width ).rounded(), maxFrame), 0)
        let y = max(min(((height - Float(cgPoint.y)) * maxValue / height ).rounded(), maxValue), 0)
        
        return Point(x: x, y: y)
    }
    
}

class GridLayer: CALayer {
    
    var max: Point!
    
    init(frame: CGRect, max: Point) {
        super.init()
        self.frame = frame
        self.max = max
        opacity = 0.6
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func setup(){
        sublayers?.forEach({$0.removeFromSuperlayer()})
        var interval = CGPoint(x: 5, y: 10)
        let gridMaxVerticalLines = PlotSettings.gridMaxVerticalLines
        let gridMaxHorizontalLines = PlotSettings.gridMaxHorizontalLines
        while CGFloat(max.x)/interval.x > gridMaxVerticalLines {
            interval.x *= 2
        }
        while CGFloat(max.y)/interval.y > gridMaxHorizontalLines {
            interval.y *= 2
        }
        
        drawVerticalLines(maxX: CGFloat(max.x), interval: interval.x)
        drawHorizontalLines(maxY: CGFloat(max.y), interval: interval.y)
    }
    
    func drawHorizontalLines(maxY: CGFloat, interval: CGFloat) {
        
        let gridHorizontalLineWidth = PlotSettings.gridHorizontalLineWidth
        let gridHorizontalLineColor = PlotSettings.gridHorizontalLineColor
        // Number of lines.
        let n = Int(maxY / interval)
        
        let gridHeight = frame.height / maxY * interval
        for i in 1...n-1 {
            let start = CGPoint(x: 0, y: bounds.height - gridHeight*CGFloat(i))
            let end = CGPoint(x: bounds.width, y: bounds.height - gridHeight*CGFloat(i))
            drawLine(start: start, end: end, width: gridHorizontalLineWidth, color: gridHorizontalLineColor)
            drawYLabels(string: String(Int(interval)*i), position: start)
        }
    }
    
    func drawVerticalLines(maxX: CGFloat, interval: CGFloat) {
        
        let gridVerticalLineWidth = PlotSettings.gridVerticalLineWidth
        let gridVerticalLineColor = PlotSettings.gridVerticalLineColor
        // Number of lines.
        let n = Int(maxX / interval)
        
        let gridWidth = frame.width / maxX * interval
        guard n>0 else {return}
        for i in 1...n {
            let start = CGPoint(x: gridWidth*CGFloat(i), y: 0)
            let end = CGPoint(x: gridWidth*CGFloat(i), y: bounds.height)
            drawLine(start: start, end: end, width: gridVerticalLineWidth, color: gridVerticalLineColor)
            drawXLabels(string: String(Int(interval)*i), position: end)
        }
    }
    
    func drawXLabels(string: String, position: CGPoint) {
        let textLayer =  CATextLayer()
        textLayer.string = string
        textLayer.fontSize = PlotSettings.textSize
        textLayer.frame = bounds
        textLayer.foregroundColor = PlotSettings.textColor
        textLayer.anchorPoint = CGPoint(x: 0, y: 0)
        textLayer.position.x = position.x + 3
        textLayer.position.y = position.y - textLayer.fontSize
        addSublayer(textLayer)
    }
    
    func drawYLabels(string: String, position: CGPoint) {
        let textLayer =  CATextLayer()
        textLayer.string = string
        textLayer.fontSize = PlotSettings.textSize
        textLayer.frame = bounds
        textLayer.foregroundColor = PlotSettings.textColor
        
        textLayer.anchorPoint = CGPoint(x: 0, y: 0)
        textLayer.position.x = position.x
        textLayer.position.y = position.y - textLayer.fontSize - 3
        addSublayer(textLayer)
    }
}

extension CALayer {
    func drawLine(start: CGPoint, end: CGPoint, width: CGFloat, color: CGColor){
        let layer = CAShapeLayer()
        layer.frame = bounds
        let line = UIBezierPath()
        line.move(to: CGPoint(x: start.x, y: bounds.height - start.y))
        line.addLine(to: CGPoint(x: end.x, y: bounds.height - end.y))
        layer.lineWidth = width
        layer.strokeColor = color
        
        layer.path = line.cgPath
        addSublayer(layer)
    }
}

class BezierPathPointView: PointView {
    var isSelected: Bool = true
    {
        didSet {
            controlPoint1?.isHidden = !isSelected
            controlPoint2?.isHidden = !isSelected
        }
    }
    
    var controlPoint1: ControlPointView? {
        willSet {
            controlPoint1?.removeFromSuperview()
        }
    }
    var controlPoint2: ControlPointView? {
        willSet {
            controlPoint2?.removeFromSuperview()
        }
    }
    
    override init(_ position: CGPoint) {
        super.init(position)
        
        backgroundColor = .black
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented")
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: -10, dy: -10)
        return frame.contains(point) ? self : nil
    }

}


class ControlPointView: PointView {
    static func inDirection(of point: BezierPathPointView, for parent: BezierPathPointView) -> ControlPointView {
        let direction = (point.center - parent.center) / parent.center.distance(from: point.center)
        let position = parent.center + direction * 30
        return ControlPointView(position, for: parent)
    }
    
    static func smoothBetween(previous: BezierPathPointView, next: BezierPathPointView, for parent: inout BezierPathPointView) {
        let distance1 = (previous.center - parent.center)/2
        let controlPoint1 = ControlPointView(parent.center + CGPoint(x: distance1.x, y: 0), for: parent)
        let distance2 = (next.center - parent.center)/2
        let controlPoint2 = ControlPointView(parent.center + CGPoint(x: distance2.x, y: 0), for: parent)
        
        parent.controlPoint1 = controlPoint1
        parent.controlPoint2 = controlPoint2
    }
    
    weak var parent: BezierPathPointView!
    var relativePosition: CGPoint {
        return self.center - parent.center
    }
    var pathLayer = CAShapeLayer()
    
    init(_ position: CGPoint, for point: BezierPathPointView) {
        super.init(position)
        self.parent = point
        self.isHidden = false
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 3.0
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.strokeColor = UIColor.gray.cgColor
        pathLayer.lineWidth = 1.0
        self.layer.addSublayer(pathLayer)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = CGMutablePath()
        
        var a = superview!.convert(self.center, to: self)
        var b = superview!.convert(self.parent.center, to: self)
        
        a = b.pointAtLine(to: a, distance: a.distance(from: b)-ControlPointView.radius)
        b = a.pointAtLine(to: b, distance: a.distance(from: b)-BezierPathPointView.radius)
        
        path.move(to: a)
        path.addLine(to: b)
        
        pathLayer.path = path
    }
    
    override func moveTo(_ position: CGPoint) {
        super.moveTo(position)
        self.setNeedsDisplay()
    }
    
    func reduce(_ n:CGFloat) -> CGPoint{
        let distance = self.center.distance(from: parent.center)
        if distance > ControlPointView.radius*2 {
            self.center = parent.center.pointAtLine(to: self.center, distance: distance-n)
            self.setNeedsDisplay()
        }
        return self.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented")
    }
}

class PointView: UIView {
    static var radius:CGFloat = 10
    
    init(_ position: CGPoint) {
        
        let frame = CGRect(x: position.x - PointView.radius, y: position.y - PointView.radius, width: PointView.radius*2, height: PointView.radius*2)
        super.init(frame: frame)
        
        self.backgroundColor = .black
        self.layer.cornerRadius = PointView.radius
    }
    
    func moveTo(_ position: CGPoint) {
        self.center = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inset:CGFloat = -20
        let expandedBounds = self.bounds.insetBy(dx: inset , dy: inset)
        return expandedBounds.contains(point)
    }
}


