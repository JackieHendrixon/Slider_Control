//
//  Joystick.swift
//  Joysticks
//
//  Created by Franek on 17/01/2020.
//  Copyright ©  2020 Frankie. All rights reserved.
//

import UIKit


protocol JoystickDelegate {
    // Called when joystick changes position.
    func didUpdate(data: JoystickData)
}

// Encapsulates data send from joystick.
//    x, y - position in cartesian coordinate system, from -100 to 100
//    angle - angle in polar coordinate system, from 0 to 360, 0 is North, rises clockwise
//    mod - modulus in polar coordinate system, from 0 to 100

struct JoystickData {
    var x: CGFloat
    var y: CGFloat
    var angle: CGFloat
    var mod: CGFloat
    
    init(x: CGFloat, y: CGFloat){
        self.x = x
        self.y = y
        self.angle = atan2(-x, y) + CGFloat.pi
        self.mod = (x*x + y*y).squareRoot()
    }
}

class Joystick: UIView {

    // MARK: Properties
    
    var backgroundLayer: CALayer { return layer }
    var stickView: UIView = UIView()
    var stickHomePosition = CGPoint()
    
    var delegate: JoystickDelegate?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundView()
        setStickView()
        addPanGestureRecognizer()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setBackgroundView()
        setStickView()
        addPanGestureRecognizer()
    }

    // MARK: Private functions
    
    private func setBackgroundView() {
        self.layer.backgroundColor = UIColor.red.cgColor
        self.layer.cornerRadius = self.layer.bounds.width/2
    }
    private func setStickView() {
        // Set position in superview.
        stickView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        stickView.bounds.size = CGSize(width: 30, height: 30)
        stickHomePosition = stickView.center
        
        // Set shape and color.
        stickView.layer.backgroundColor = UIColor.blue.cgColor
        stickView.layer.cornerRadius = stickView.layer.bounds.width/2
        stickView.layer.opacity = 0.7
        
        self.addSubview(stickView)
    }
    
    private func addPanGestureRecognizer() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector (self.handlePan(_:)))
        stickView.addGestureRecognizer(pan)
        stickView.isUserInteractionEnabled = true
    }

    //MARK: Actions
    
    @IBAction func handlePan(_ gestureRecognizer : UIPanGestureRecognizer) {
        // Distance from the place where touch began.
        var translation = gestureRecognizer.translation(in: self)
        
        if gestureRecognizer.state == .changed  {
            
            // Calculate distance from the center and backgroundView circle radius.
            let dist = (translation.x*translation.x+translation.y*translation.y).squareRoot()
            let radius = self.bounds.size.width/2
            
            // Clamp translation parameter to not leave backgroundView circle.
            if dist > radius {
                translation.x = translation.x*radius/dist
                translation.y = translation.y*radius/dist
            }
            
            // Animate movement.
            UIView.animate(withDuration: 0.2, animations:{
                // Move the stickView to new position.
                self.stickView.center = CGPoint(x: self.stickHomePosition.x + translation.x, y: self.stickHomePosition.y + translation.y)
            })
            
            // Pass data to JoystickDelegate.
            let data = JoystickData(x: translation.x*100/radius, y: translation.y*100/radius)
            delegate?.didUpdate(data: data)
        }
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            // Animate movement.
            UIView.animate(withDuration: 0.2, animations:{
                // Move the stickView to home position.
                self.stickView.center = self.stickHomePosition
            })
        }
    }
}
