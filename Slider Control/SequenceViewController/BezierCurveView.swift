////
////  BezierCurveView.swift
////  MSF Slider
////
////  Created by Franek on 07/05/2020.
////  Copyright © 2020 Frankie. All rights reserved.
////
//
//import UIKit
//
//class TestViewController:UIViewController {
//    var sequenceViewModel = SequenceViewModel.testObject()
//    
//    var scrollView: UIScrollView!
//    
//    var plot: Plot!
//    
//    var selectedPoint: PointView?
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//        self.edgesForExtendedLayout = []
//        
//        scrollView = UIScrollView(frame: .zero)
//        scrollView.backgroundColor = .red
//        self.view.addSubview(scrollView)
//        
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        setupGestureRecognizers()
//        
//        self.view.backgroundColor = .green
//      
//    }
//    
//    override func loadView() {
//        super.loadView()
//        
//    }
//    
//    override func viewWillLayoutSubviews() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaTopAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaBottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLeadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaTrailingAnchor)
//            ])
//       
//    }
//    
//    override func viewDidLayoutSubviews() {
//        setupPlot()
//    }
//    
//    
//    private func setupGestureRecognizers() {
//        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
//        singleTapGestureRecognizer.numberOfTapsRequired = 1
//        self.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
//        
//        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
//        doubleTapGestureRecognizer.numberOfTapsRequired = 2
//        self.scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
//        
//        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
//        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
//        self.scrollView.addGestureRecognizer(panGestureRecognizer)
//        
//        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
//        self.scrollView.addGestureRecognizer(pinchGestureRecognizer)
//        
//    }
//    
//    private func setupPlot(){
//        
//        
//        scrollView.contentSize = .init(width: self.scrollView.frame.width * 2,
//                                        height: self.scrollView.frame.height)
//        
//        self.plot = sequenceViewModel.getPlot(beginningFrame: 0,
//                                              endingFrame: 120,
//                                              for: CGRect(x: 0,
//                                                          y: 0,
//                                                          width: self.scrollView.frame.width * 2,
//                                                          height: self.scrollView.frame.height),
//                                              type: SlideKeyframe.self)
//        
//        self.scrollView.addSubview(self.plot.grid)
//        self.scrollView.addSubview(self.plot)
//        
//        
//    }
//    
//    @objc func didSingleTap(_ sender: UITapGestureRecognizer) {
//        
//        let location = sender.location(in: self.scrollView)
//        
//        if let selectedPoint = self.scrollView.hitTest(location, with: nil) as? PointView {
//            if let point = selectedPoint as? BezierPathPointView {
//                plot!.selectedPoint = point
//            }
//            
//        } else {
//            if plot!.selectedPoint == nil {
//                if plot!.drawableArea.contains(location) {
//                    let point = BezierPathPointView(location)
//                    plot!.addNewPoint(point)
//                }
//                
//            } else {
//                plot!.selectedPoint = nil
//            }
//        }
//    }
//    
//    @objc func didDoubleTap(_ sender: UITapGestureRecognizer) {
//        let location = sender.location(in: self.scrollView)
//        
//        if let selectedPoint = self.scrollView.hitTest(location, with: nil) as? BezierPathPointView {
//            plot?.deletePoint(selectedPoint)
//        } else {
//            
//        }
//    }
//    
//    @objc func didPan(_ sender: UIPanGestureRecognizer) {
//        var location = sender.location(in: self.scrollView)
//        
//        if sender.state == .began {
//            if let selectedPoint = self.scrollView.hitTest(location, with: nil) as? PointView {
//                self.selectedPoint = selectedPoint
//                print(Date().timeIntervalSince1970)
//            }
//        } else if sender.state == .changed  {
//            
//            if let selectedPoint = self.selectedPoint {
//                
//                if !plot!.drawableArea.contains(location) {
//                    if location.x > plot!.drawableArea.maxX {
//                        location.x = plot!.drawableArea.maxX
//                    }
//                    if location.x < plot!.drawableArea.minX {
//                        location.x = plot!.drawableArea.minX
//                    }
//                    if location.y > plot!.drawableArea.maxY {
//                        location.y = plot!.drawableArea.maxY
//                    }
//                    if location.y < plot!.drawableArea.minY {
//                        location.y = plot!.drawableArea.minY
//                    }
//                }
//                if let controlPoint = selectedPoint as? ControlPointView {
//                    
//                    plot?.movePoint(controlPoint, to: location)
//                } else if let selectedPoint = selectedPoint as? BezierPathPointView {
//                    plot?.movePoint(selectedPoint, to: location)
//                }
//                
//            } else {
////                let contentOffset = self.scrollView.contentOffset
////                let velocity = sender.velocity(in: self.scrollView)
////
////                self.scrollView.setContentOffset(contentOffset+velocity, animated: true)
//            }
//            
//        } else if sender.state == .ended {
//            self.selectedPoint = nil
//           
//        }
//    }
//    
//    @objc func didPinch(_ sender: UIPinchGestureRecognizer) {
//        //        let location = sender.location(in: self.view)
//        
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("coder not implemented")
//    }
//}
//
//
//class Grid: UIView {
//    
//    var lines: [(CGPoint,CGPoint)]?
//    
//    var pathLayer = CAShapeLayer()
//
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .clear
//        
//        self.layer.addSublayer(pathLayer)
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        if let lines = lines {
//            pathLayer.sublayers = []
//            drawLines(lines)
//        }
//    }
//    
//    
//    private func drawLines(_ lines: [(CGPoint, CGPoint)] ){
//        
//        for (point1,point2) in lines {
//            let path = CGMutablePath()
//            path.move(to: point1)
//            path.addLine(to: point2)
//            let layer = CAShapeLayer()
//            layer.fillColor = UIColor.clear.cgColor
//            layer.lineWidth = 1
//            layer.strokeColor = UIColor.lightGray.cgColor
//            layer.path = path
//            self.pathLayer.addSublayer(layer)
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("coder not implemented")
//    }
//}
//
//
//class Plot: UIView{
//    
//    var points = [BezierPathPointView]()
//    
//    var plotPathLayer = CAShapeLayer()
//    
//    var drawableArea: CGRect {
//        let inset:CGFloat = 10
//        return frame.inset(by: UIEdgeInsets(top: inset,
//                                                    left: inset,
//                                                    bottom: inset,
//                                                    right: inset) )
//    }
//    
//    var grid: Grid!
//    
//    weak var selectedPoint: BezierPathPointView? {
//        willSet {
//            if let newValue = newValue {
//                newValue.isSelected = true
//                
//            }
//            if let selectedPoint = selectedPoint {
//                    selectedPoint.isSelected = false
//                }
//            }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//       
//        let drawableView = UIView(frame: drawableArea)
//        drawableView.layer.borderColor = UIColor.black.cgColor
//        drawableView.layer.borderWidth = 2
//        self.addSubview(drawableView)
//        
//        self.backgroundColor = .clear
//      
//        plotPathLayer.fillColor = UIColor.clear.cgColor
//        plotPathLayer.strokeColor = UIColor.blue.cgColor
//        plotPathLayer.lineWidth = 2.0
//        self.layer.addSublayer(plotPathLayer)
//        
//    }
//    
//    override func draw(_ rect: CGRect) {
//        
//        guard points.count>1 else {
//            plotPathLayer.path = nil
//            return
//        }
//        
//        let plotPath = UIBezierPath()
//        plotPath.move(to: points[0].center)
//        
//        for i in 1...points.count-1 {
//            if let controlPoint1 = points[i-1].controlPoint2, let controlPoint2 = points[i].controlPoint1 {
//                plotPath.addCurve(to: points[i].center, controlPoint1: controlPoint1.center, controlPoint2: controlPoint2.center)
//            }
//        }
//        plotPathLayer.path = plotPath.cgPath
//    }
//    
//    func addNewPoint(_ point: BezierPathPointView) {
//        guard !points.contains(point) else { return }
//        
//        if let i = points.firstIndex(where: {$0.center.x > point.center.x}) {
//            points.insert(point, at: i)
//        } else  {
//            points.append(point)
//        }
//        
//        let i = points.firstIndex(of: point)!
//        
//        switch points.count {
//        case 1:
//            break
//        case 2:
//            points[0].controlPoint2 = ControlPointView.inDirection(of: points[1], for: points[0])
//            self.addSubview(points[0].controlPoint2!)
//            points[1].controlPoint1 = ControlPointView.inDirection(of: points[0], for: points[1])
//            self.addSubview(points[1].controlPoint1!)
//            
//        default:
//            if point == points.first {
//                point.controlPoint2 = ControlPointView.inDirection(of: points[1], for: point)
//                self.addSubview(point.controlPoint2!)
//                ControlPointView.smoothBetween(previous: point, next: points[i+2], for: &points[i+1])
//                self.addSubview(points[i+1].controlPoint1!)
//                self.addSubview(points[i+1].controlPoint2!)
//                
//            } else if point == points.last {
//                point.controlPoint1 = ControlPointView.inDirection(of: points[points.count-2], for: point)
//                self.addSubview(point.controlPoint1!)
//                ControlPointView.smoothBetween(previous: points[i-2], next: point, for: &points[i-1])
//                self.addSubview(points[i-1].controlPoint1!)
//                self.addSubview( points[i-1].controlPoint2!)
//            } else {
//                ControlPointView.smoothBetween(previous: points[i-1], next: points[i+1], for: &points[i])
//                
//                self.addPointsBetween(points[i-1], points[i])
//                
//                self.addSubview(point.controlPoint1!)
//                self.addSubview(point.controlPoint2!)
//            }
//        }
//        
//        self.addSubview(point)
//        self.setNeedsDisplay()
//    }
//    
//    func addPoint(_ point: BezierPathPointView) {
//        
//        points.append(point)
//        self.addSubview(point)
//        if let controlPoint1 = point.controlPoint1 {
//            self.addSubview(controlPoint1)
//        }
//        if let controlPoint2 = point.controlPoint2 {
//            self.addSubview(controlPoint2)
//        }
//    }
//    
//    
//    
//    func movePoint(_ point: BezierPathPointView, to destination: CGPoint) {
//
//        let validatedDestination = validate(position: destination, for: point)
//        point.moveTo(validatedDestination)
//        
//        self.setNeedsDisplay()
//    }
//    
//    func movePoint(_ controlPoint: ControlPointView, to destination: CGPoint) {
//        
//        let validatedDestination = validate(position: destination, for: controlPoint)
//        controlPoint.moveTo(validatedDestination)
//        
//        updateSecondControlPoint(for: controlPoint)
//        
//        self.setNeedsDisplay()
//    }
//    
//    func deletePoint(_ point: BezierPathPointView) {
//        guard points.contains(point) else { return }
//        
//        switch points.count {
//        case 1:
//            break
//        case 2:
//            if point != points.first {
//                points[0].controlPoint2 = nil
//            } else {
//                points[1].controlPoint1 = nil
//            }
//            
//        default:
//            if point == points.last {
//                points[points.count-2].controlPoint2 = nil
//                point.controlPoint1 = nil
//            } else if point == points.first {
//                points[1].controlPoint1 = nil
//                points[1].controlPoint1 = nil
//                point.controlPoint2 = nil
//            }
//        }
//        
//        point.controlPoint1 = nil
//        point.controlPoint2 = nil
//        
//        points = points.filter({$0 !== point})
//        
//        point.removeFromSuperview()
//        self.setNeedsDisplay()
//    }
//    
//    private func validate(position: CGPoint, for point: BezierPathPointView) -> CGPoint {
//        let i = points.firstIndex(of: point)!
//        
//        var validatedPosition = position
//        
//        if i > 0 {
//            let previous = points[i-1]
//            let limit = previous.center.x + BezierPathPointView.radius*2
//            if position.x < limit  {
//                validatedPosition.x = limit
//            }
//         
//            if let c1 = previous.controlPoint2?.center, let controlPointRelativePosition = point.controlPoint1?.relativePosition  {
//                let c0 = previous.center
//                let c2 = position + controlPointRelativePosition
//                let c3 = position
//                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3) {
//                    let c3 = point.center
//                    while !Math.isSingleValuedBezier(c0: c0, c1: previous.controlPoint2!.reduce(1),
//                                                    c2: point.controlPoint1!.reduce(1),
//                                                    c3: c3) {
//                    }
//                }
//            }
//        
//            
//        }
//        
//        if i < points.count-1 {
//            let next = points[i+1]
//            let limit = next.center.x - BezierPathPointView.radius*2
//            if position.x > limit  {
//                validatedPosition.x = limit
//            }
//            
//            if let c2 = next.controlPoint1?.center, let controlPointRelativePosition = point.controlPoint2?.relativePosition {
//                let c0 = position
//                let c1 = position + controlPointRelativePosition
//                let c3 = next.center
//                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3) {
//                    let c0 = point.center
//                    while !Math.isSingleValuedBezier(c0: c0, c1: point.controlPoint2!.reduce(1),
//                                                     c2: next.controlPoint1!.reduce(1),
//                                                     c3: c3) {
//                    }
//                }
//            }
//        }
//        
//        if let controlPoint1 = point.controlPoint1 {
//            controlPoint1.moveTo(validatedPosition + controlPoint1.relativePosition)
//        }
//        
//        if let controlPoint2 = point.controlPoint2 {
//            controlPoint2.moveTo(validatedPosition + controlPoint2.relativePosition)
//        }
//        
//        return validatedPosition
//
//    }
//    
//    private func validate(position: CGPoint, for controlPoint: ControlPointView) -> CGPoint {
//        var validatedPosition = position
//        
//        if controlPoint === controlPoint.parent.controlPoint1 {
//            if position.x >= controlPoint.parent.center.x {
//                validatedPosition.x = controlPoint.parent.center.x - 1
//            }
//        } else {
//            if position.x <= controlPoint.parent.center.x {
//                validatedPosition.x = controlPoint.parent.center.x + 1
//            }
//        }
//        
//        let minDistanceFromParent:CGFloat = BezierPathPointView.radius + ControlPointView.radius
//        if validatedPosition.distance(from: controlPoint.parent.center) < minDistanceFromParent {
//            let y = validatedPosition.y - controlPoint.parent.center.y
//            
//            if controlPoint === controlPoint.parent.controlPoint1 {
//                validatedPosition.x = controlPoint.parent.center.x - (minDistanceFromParent*minDistanceFromParent-y*y).squareRoot()
//            } else {
//                validatedPosition.x = controlPoint.parent.center.x + (minDistanceFromParent*minDistanceFromParent-y*y).squareRoot()
//            }
//        }
//        
//        let i = points.firstIndex(of: controlPoint.parent)!
//        
//        if i > 0, controlPoint === controlPoint.parent.controlPoint1 {
//            
//            
//            if let c1 = points[i-1].controlPoint2?.center {
//                let c0 = points[i-1].center
//                let c2 = validatedPosition
//                let c3 = controlPoint.parent.center
//                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3 ) {
//                    validatedPosition.x = controlPoint.center.x
//                }
//            }
//        }
//        
//        if i < points.count - 1, controlPoint === controlPoint.parent.controlPoint2 {
//            if let c2 = points[i+1].controlPoint1?.center {
//                let c0 = controlPoint.parent.center
//                let c1 = validatedPosition
//                let c3 = points[i+1].center
//                if !Math.isSingleValuedBezier(c0: c0, c1: c1, c2: c2, c3: c3 ) {
//                    validatedPosition.x = controlPoint.center.x
//                }
//            }
//        }
//
//        return validatedPosition
//    }
//    
//    private func updateSecondControlPoint(for controlPoint: ControlPointView) {
//        var secondControlPoint: ControlPointView?
//        
//        if controlPoint === controlPoint.parent.controlPoint1 {
//            secondControlPoint = controlPoint.parent.controlPoint2
//        } else {
//            secondControlPoint = controlPoint.parent.controlPoint1
//        }
//        
//        if let secondControlPoint = secondControlPoint {
//            let distance = secondControlPoint.center.distance(from: controlPoint.parent.center)
//            let newPosition = controlPoint.parent.center.pointAtLine(to: controlPoint.center, distance: -distance)
//            secondControlPoint.moveTo(newPosition)
//        }
//    }
//    
//    private func addPointsBetween(_ point1: BezierPathPointView, _ point2: BezierPathPointView) {
//        let points = calculatePointBetween(point1,point2)
//        for point in points {
//            let point = PointView(point)
//            point.backgroundColor = .red
//            self.addSubview(point)
//        }
//    }
//    
//    private func calculatePointBetween(_ point1: BezierPathPointView, _ point2: BezierPathPointView) -> [CGPoint] {
//        var result = [CGPoint]()
//        
//        let c0 = point1.center
//        let c3 = point2.center
//        let x = c0.x + 20
//        if let c1 = point1.controlPoint2?.center, let c2 = point2.controlPoint1?.center {
//            result = Math.calcuatePointsOnBezierCurve(for: x, c0: c0, c1: c1, c2: c2, c3: c3)
//        }
//        return result
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("coder not implemented")
//    }
//}
//
//
//class BezierPathPointView: PointView {
//    var isSelected: Bool = true
//    {
//        didSet {
//            controlPoint1?.isHidden = !isSelected
//            controlPoint2?.isHidden = !isSelected
//        }
//    }
//    
//    var controlPoint1: ControlPointView? {
//        willSet {
//            controlPoint1?.removeFromSuperview()
//        }
//    }
//    var controlPoint2: ControlPointView? {
//        willSet {
//            controlPoint2?.removeFromSuperview()
//        }
//    }
//    
//    override init(_ position: CGPoint) {
//        super.init(position)
//        
//        backgroundColor = .orange
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("coder not implemented")
//    }
//}
//
//
//class ControlPointView: PointView {
//    static func inDirection(of point: BezierPathPointView, for parent: BezierPathPointView) -> ControlPointView {
//        let direction = (point.center - parent.center) / parent.center.distance(from: point.center)
//        let position = parent.center + direction * 30
//        return ControlPointView(position, for: parent)
//    }
//    
//    static func smoothBetween(previous: BezierPathPointView, next: BezierPathPointView, for parent: inout BezierPathPointView) {
//        let distance1 = (previous.center - parent.center)/2
//        let controlPoint1 = ControlPointView(parent.center + CGPoint(x: distance1.x, y: 0), for: parent)
//        let distance2 = (next.center - parent.center)/2
//        let controlPoint2 = ControlPointView(parent.center + CGPoint(x: distance2.x, y: 0), for: parent)
//        
//        parent.controlPoint1 = controlPoint1
//        parent.controlPoint2 = controlPoint2
//    }
//    
//    weak var parent: BezierPathPointView!
//    var relativePosition: CGPoint {
//        return self.center - parent.center
//    }
//    var pathLayer = CAShapeLayer()
//    
//    init(_ position: CGPoint, for point: BezierPathPointView) {
//        super.init(position)
//        self.parent = point
//        self.isHidden = false
//        self.backgroundColor = UIColor.clear
//        self.layer.borderColor = UIColor.gray.cgColor
//        self.layer.borderWidth = 3.0
//        pathLayer.fillColor = UIColor.clear.cgColor
//        pathLayer.strokeColor = UIColor.gray.cgColor
//        pathLayer.lineWidth = 1.0
//        self.layer.addSublayer(pathLayer)
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        let path = CGMutablePath()
//        
//        var a = superview!.convert(self.center, to: self)
//        var b = superview!.convert(self.parent.center, to: self)
//        
//        a = b.pointAtLine(to: a, distance: a.distance(from: b)-ControlPointView.radius)
//        b = a.pointAtLine(to: b, distance: a.distance(from: b)-BezierPathPointView.radius)
//        
//        path.move(to: a)
//        path.addLine(to: b)
//        
//        pathLayer.path = path
//    }
//    
//    override func moveTo(_ position: CGPoint) {
//        super.moveTo(position)
//        self.setNeedsDisplay()
//    }
//    
//    func reduce(_ n:CGFloat) -> CGPoint{
//        let distance = self.center.distance(from: parent.center)
//        if distance > ControlPointView.radius*2 {
//            self.center = parent.center.pointAtLine(to: self.center, distance: distance-n)
//            self.setNeedsDisplay()
//        }
//        return self.center
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("coder not implemented")
//    }
//}
//
//class PointView: UIView {
//    static var radius:CGFloat = 10
//    
//    init(_ position: CGPoint) {
//        
//        let frame = CGRect(x: position.x - PointView.radius, y: position.y - PointView.radius, width: PointView.radius*2, height: PointView.radius*2)
//        super.init(frame: frame)
//        
//        self.backgroundColor = .black
//        self.layer.cornerRadius = PointView.radius
//    }
//    
//    func moveTo(_ position: CGPoint) {
//        self.center = position
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("coder not implemented")
//    }
//    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let inset:CGFloat = -20
//        let expandedBounds = self.bounds.insetBy(dx: inset , dy: inset)
//        return expandedBounds.contains(point)
//    }
//}
//
//
