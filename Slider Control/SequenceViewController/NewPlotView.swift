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

class NewPlotView: UIView {
    var gridLayer: GridLayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.gridLayer = GridLayer(frame: self.frame, max: .init(x: 30, y: 30))
    }
    
}


class GridLayer: CALayer {
    
    var start: CGPoint = .init(x: 0, y: 0)
    
    var end: CGPoint = .init(x:200, y:100)
    
    init(frame: CGRect, max: CGPoint) {
        super.init()
        self.frame = frame
        
        opacity = 0.6
        var interval = CGPoint(x: 5, y: 10)
        let gridMaxVerticalLines = PlotSettings.gridMaxVerticalLines
        let gridMaxHorizontalLines = PlotSettings.gridMaxHorizontalLines
        while max.x/interval.x > gridMaxVerticalLines {
            interval.x *= 2
        }
        while max.y/interval.y > gridMaxHorizontalLines {
            interval.y *= 2
        }
        
        drawVerticalLines(maxX: max.x, interval: interval.x)
        drawHorizontalLines(maxY: max.y, interval: interval.y)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
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

