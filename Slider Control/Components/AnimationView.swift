//
//
//  SliderView.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class AnimationSettings {
    var railWidth: CGFloat = 10
    var railColor: CGColor = UIColor.orange.cgColor
    
    var headRadius: CGFloat = 20
    var headColor: CGColor = Settings.orangeColor.cgColor
    
    var visionFieldRadius: CGFloat = 60
    var visionFieldColor: CGColor = Settings.orangeColor.cgColor
    
}

class AnimationView: UIView {
    
    // MARK: - Properties

    var settings: AnimationSettings = AnimationSettings()
    
    override var bounds: CGRect {
        didSet {
            update()
        }
    }
    
    var withRail: Bool = true
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        GlobalTimecode.delegates.append(self)
        SliderController.instance.slider.delegates.append(self)
    }
    
    // MARK: - Private Functions
    
    private func setupBackground() {
        self.layer.backgroundColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.layer.bounds.size.height/10
    }
    
    func draw(position: CGFloat, angle: CGFloat) {
        layer.sublayers?.removeAll()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let radians = angle * CGFloat.pi / 180
        
        var railWidth: CGFloat = 0
        if withRail{
            railWidth = bounds.width*0.7
            let railShape = RailShape(size: CGSize(width: railWidth, height: 10), center: center)
            layer.addSublayer(railShape)
        }
        
        let movedCenter = CGPoint(x: center.x - railWidth/2 + railWidth*(position/100), y: center.y)
        
        let visionFieldShape = VisionFieldShape(angle: 1.4, center: movedCenter, settings: settings)
        visionFieldShape.transform = CATransform3DMakeRotation(radians, 0, 0, 1)
        layer.addSublayer(visionFieldShape)
        
        let headShape = HeadShape(radius: 20, center: movedCenter)
        layer.addSublayer(headShape)
        
    }
    
    func update(){
        var parameters: Parameters
        if SliderController.instance.slider.mode == .sequence {
            parameters = Sequence.instance.calculateParameters(for: GlobalTimecode.current)
            if withRail {
                draw(position: CGFloat(parameters.x), angle: CGFloat(parameters.pan) + 45)
            } else {
                draw(position: 0, angle: (-CGFloat(parameters.tilt) + 135))
            }
        } else {
            parameters = SliderController.instance.slider.currentPosition
            UIView.animate(withDuration: SliderController.instance.refreshTime, animations: {
                if self.withRail {
                    self.draw(position: CGFloat(parameters.x), angle:  CGFloat(parameters.pan) + 45)
                } else {
                    self.draw(position: 0, angle: (-CGFloat(parameters.tilt) + 135))
                }
            })
        }
        
        
        
    }
    
}

extension AnimationView: GlobalTimecodeDelegate {
    func didUpdateGlobalTimecode() {
        update()
    }
}

extension AnimationView: SequenceDelegate {
    func didUpdate() {
        update()
    }
}
extension AnimationView: SliderDelegate {
    func didUpdatePosition() {
        update()
    }
    func didUpdateSpeed() {
        
    }
}

class VisionFieldShape: CAShapeLayer {
    init(angle: CGFloat, center: CGPoint, settings: AnimationSettings) {
        super.init()
        
        let radius = settings.visionFieldRadius
        
        frame = CGRect(x: center.x - radius, y: center.y - radius,
                       width: radius * 2, height: radius * 2)
    
        let innerCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let newPath = UIBezierPath()
        
        newPath.move(to: innerCenter)
        newPath.addArc(withCenter: innerCenter, radius: radius,
                       startAngle: -CGFloat.pi/2 - angle/2,
                       endAngle: -CGFloat.pi/2 + angle/2, clockwise: true)
        newPath.addLine(to: innerCenter)
        path = newPath.cgPath

        opacity = 0.8
        fillColor = settings.visionFieldColor
        shadowRadius = 7
        shadowOpacity = 0.2
        shadowColor = UIColor.black.cgColor
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Required init not implemented")
    }
    
    
}


class HeadShape: CAShapeLayer {
    
    init(radius: CGFloat, center: CGPoint) {
        super.init()
        frame = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)

        cornerRadius = radius
        
        shadowRadius = 10
        shadowOpacity = 0.15
        shadowColor = UIColor.black.cgColor
        
        backgroundColor = UIColor.black.cgColor
        opacity = 1
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Required init not implemented")
    }
}

class RailShape: CAShapeLayer{
    init(size: CGSize, center: CGPoint) {
        super.init()
        frame = CGRect(x: center.x - size.width/2, y: center.y - size.height/2, width: size.width, height: size.height)
        
        cornerRadius = size.height/3
        
        backgroundColor = UIColor.black.cgColor
        opacity = 1
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Required init not implemented")
    }
}
