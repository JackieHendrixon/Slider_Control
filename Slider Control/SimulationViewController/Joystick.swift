//
//  Joystick.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import UIKit

protocol JoystickDelegate {
    // Called when joystick changes position.
    func didUpdate(data: JoystickData, sender: Joystick)
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
    var name: String = ""
    
    var stickView: UIView!
    var stickHomePosition = CGPoint()
    
    override var bounds: CGRect {
        didSet {
            updateBackgroundView()
            updateStickView()
        }
    }
    
    var delegate: JoystickDelegate?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateBackgroundView()
        
        stickView = UIView()
        self.addSubview(stickView)
        updateStickView()
        
        addPanGestureRecognizer()
    }
    
    // MARK: Private functions
    private func updateBackgroundView(){
        self.layer.backgroundColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = self.layer.bounds.width/2
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor.appOrange.cgColor
    }
    
    private func updateStickView() {
        // Set position in superview.
        //stickView.frame = CGRect(origin: self.bounds.origin, size: self.bounds.size)
        stickView.bounds.size = CGSize(width:  self.bounds.width*0.65, height: self.bounds.width*0.65)
        stickView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        stickHomePosition = stickView.center
        
        // Set shape and color.
        stickView.layer.backgroundColor = UIColor.white.cgColor
        stickView.layer.cornerRadius = stickView.layer.bounds.width/2
        stickView.layer.opacity = 0.3
        stickView.layer.shadowColor = UIColor.black.cgColor
        stickView.layer.shadowRadius = 30
        stickView.layer.shadowOpacity = 0.3
    }
    
    private func addPanGestureRecognizer() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector (self.handlePanGesture(_:)))
        stickView.addGestureRecognizer(pan)
        stickView.isUserInteractionEnabled = true
    }
    
    //MARK: Actions
    
    @IBAction func handlePanGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
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
            delegate?.didUpdate(data: data, sender: self)
        }
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            // Animate movement.
            UIView.animate(withDuration: 0.2, animations:{
                // Move the stickView to home position.
                self.stickView.center = self.stickHomePosition
            })
            // Pass data to JoystickDelegate.
            let data = JoystickData(x: 0, y: 0)
            delegate?.didUpdate(data: data, sender: self)
        }
    }
}
