////
////  PlotView.swift
////  Slider Control
////
////  Created by Franciszek Baron on 30/01/2020.
////  Copyright © 2020 Franciszek Baron. All rights reserved.
////
//
//import UIKit
//
//
//enum PlotType: CaseIterable{
//    case x, pan, tilt
//}
//
//
//
//class TriplePlotView: UIView {
//    let settings = PlotSettings()
//    
//    var indicator: UIView!
//    var indicatorPosition: CGFloat = 0
//    
//    var plots = [PlotView]()
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        addPlots()
//        indicator = IndicatorView(frame: CGRect(x: 0, y: 0, width: settings.indicatorWidth, height: self.frame.height))
//        updateIndicatorPosition()
//        addSubview(indicator)
//        
//        addPanGestureRecognizer()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(updateIndicatorPosition), name: .didUpdateCurrentTimecode, object: nil)
//    }
//    
//    private func addPlots(){
//        
//        plots.append(PlotView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/3), type: .x))
//        plots.append(PlotView(frame: CGRect(x: 0, y: self.frame.height/3, width: self.frame.width, height: self.frame.height/3), type: .pan))
//        plots.append(PlotView(frame: CGRect(x: 0, y: 2*self.frame.height/3, width: self.frame.width, height: self.frame.height/3), type: .tilt))
//        for plot in plots {
//            self.addSubview(plot)
//        }
//        
//    }
//    
//    
//    private func addPanGestureRecognizer(){
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        
//        indicator.addGestureRecognizer(pan)
//        indicator.isUserInteractionEnabled = true
//    }
//    
//    @IBAction func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
//        let translation = gestureRecognizer.translation(in: self)
//        
//        
//        if gestureRecognizer.state == .changed {
//            let position = self.indicatorPosition + translation.x
//            moveIndicatorTo(position: position)
//            
//            
//        }
//        else if gestureRecognizer.state == .ended {
//            indicatorPosition = self.indicator.frame.origin.x
//            if let lastFrame = Sequence.instance.keyframes?.last?.timecode.totalFrames {
//                let current = Int(indicatorPosition / (self.frame.width - self.indicator.frame.width) * CGFloat(lastFrame))
//                CurrentTimecode.current = Timecode(frames: current)
//            }
//        }
//    }
//    
//    @objc private func updateIndicatorPosition() {
//        
//        if let lastFrame = Sequence.instance.keyframes?.last?.timecode.totalFrames {
//            let position =  (self.frame.width - self.indicator.frame.width) * CGFloat(CurrentTimecode.current.totalFrames) / CGFloat(lastFrame)
//            moveIndicatorTo(position: position)
//            
//        }
//    }
//    
//    private func moveIndicatorTo(position: CGFloat) {
//        UIView.animate(withDuration: 0.2, animations: {
//            if position <= self.frame.width - self.indicator.frame.width && position >= 0 {
//                self.indicator.frame.origin.x = position
//            } else if position > self.frame.width - self.indicator.frame.width {
//                self.indicator.frame.origin.x = self.frame.width - self.indicator.frame.width
//            } else {
//                self.indicator.frame.origin.x = 0
//            }
//        })
//    }
//    
//}
//
//
//class IndicatorView: UIView {
//    let settings = PlotSettings()
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("Not implemented")
//    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        layer.backgroundColor = settings.indicatorColor
//        layer.opacity = 0.5
//        
//    }
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let frame = self.bounds.insetBy(dx: -20, dy: 0)
//        return frame.contains(point) ? self : nil
//    }
//    
//}
//
//
//class PlotView: UIView {
//    
//    let settings = PlotSettings()
//    
//    let sequence = Sequence.instance
//    
//    var points = [CGPoint]()
//    
//    var max = CGPoint()
//    
//    var type: PlotType = .x {
//        didSet{
//            draw()
//        }
//    }
//    
//    override var bounds: CGRect {
//        didSet {
//            draw()
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        
//        
//    }
//    
//    init(frame: CGRect, type: PlotType) {
//        self.type = type
//        super.init(frame: frame)
//        sequence.delegates.append(self)
//        draw()
//    }
//    
//    func draw(){
//        switch type {
//        case .x:
//            max.y = CGFloat(Keyframe.parametersRange.max.x)
//        case .pan:
//            max.y = CGFloat(Keyframe.parametersRange.max.pan)
//        case .tilt:
//            max.y = CGFloat(Keyframe.parametersRange.max.tilt)
//        }
//        
//        if let keyframes = sequence.keyframes {
//            points.removeAll()
//            if !keyframes.isEmpty{
//                
//                if let maxX = keyframes.last?.timecode.totalFrames {
//                    max.x = CGFloat(maxX)
//                } else {
//                    max.x = 0
//                }
//                
//                for i in 0...keyframes.count-1 {
//                    
//                    var y: CGFloat
//                    switch type {
//                    case .x:
//                        y = CGFloat(keyframes[i].parameters.x)
//                    case .pan:
//                        y = CGFloat(keyframes[i].parameters.pan)
//                    case .tilt:
//                        y = CGFloat(keyframes[i].parameters.tilt)
//                    }
//                    let x = CGFloat(keyframes[i].timecode.totalFrames)
//                    points.append(CGPoint(x: x, y: y))
//                    
//                }
//                
//            }
//        }
//        
//        drawGrid()
//        drawPlot(points: points)
//    }
//    
//    func drawBackground(){
//        let backgroundLayer = CALayer()
//        backgroundLayer.frame = bounds
//        backgroundLayer.backgroundColor = UIColor.white.cgColor
//        backgroundLayer.opacity = 0.5
//        
//        layer.addSublayer(backgroundLayer )
//    }
//    
//    func drawGrid(){
//        layer.sublayers?.removeAll{$0 is GridLayer }
//        let rect = CGRect(x: bounds.origin.x + settings.plotPointSize/2, y: bounds.origin.y + settings.plotPointSize/2, width: bounds.width - settings.plotPointSize, height: bounds.height - settings.plotPointSize)
//        layer.addSublayer(GridLayer(frame: rect, max: max, settings: settings))
//    }
//    
//    func drawPlot(points: [CGPoint]){
//        layer.sublayers?.removeAll{$0 is plotLayer == true }
//        let rect = CGRect(x: bounds.origin.x + settings.plotPointSize/2, y: bounds.origin.y + settings.plotPointSize/2, width: bounds.width - settings.plotPointSize, height: bounds.height - settings.plotPointSize)
//        layer.addSublayer(plotLayer(frame: rect, points: points, max: max, type: .x, settings: settings))
//    }
//
//}
//
//extension PlotView: SequenceDelegate{
//    func didUpdate() {
//        draw()
//    }
//}
//
//class plotLayer: CALayer {
//    
//    var settings: PlotSettings!
//    
//    init(frame: CGRect, points: [CGPoint], max: CGPoint, type: PlotType, settings: PlotSettings) {
//        self.settings = settings
//        
//        super.init()
//        self.frame = frame
//        opacity = 0.8
//     
//        
//        drawPlot(points: points, max: max)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("Not implemented")
//    }
//    
//    func drawPoint(point: CGPoint) {
//        let layer = CAShapeLayer()
//        layer.frame = bounds
//        
//        let size:CGFloat = settings.plotPointSize
//        let square = CGRect(x: point.x - size/2, y: bounds.height - point.y - size/2, width: size, height: size)
//        
//        let path = UIBezierPath(roundedRect: square, cornerRadius: 0)
//    
//        layer.fillColor = settings.plotPointColor
//        layer.path = path.cgPath
//        
//        addSublayer(layer)
//    }
//    
//    func drawPlot(points: [CGPoint], max: CGPoint){
//        var points = points
//        if !points.isEmpty{
//            for i in 0...points.count-1{
//                points[i].x = points[i].x * bounds.width / max.x
//                points[i].y = points[i].y * bounds.height / max.y
//                
//                if i>0 {
//                    drawLine(start: points[i-1], end: points[i], width: settings.plotLineWidth, color: settings.plotLineColor)
//                }
//            }
//            for i in 0...points.count-1{
//                drawPoint(point: points[i])
//            }
//        }
//    }
//}
//
//
