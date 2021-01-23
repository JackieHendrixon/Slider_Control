//
//  Indicator.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class Indicator: UIView {
    
    let defaultOpacity:Float = 0.6
    
    var isOn: Bool = false {
        didSet{
            if isOn {
                layer.backgroundColor = UIColor.green.cgColor
            } else {
                layer.backgroundColor = UIColor.red.cgColor
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = bounds.width/2
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = bounds.width/2
        layer.backgroundColor = UIColor.red.cgColor
        layer.opacity = defaultOpacity
        layer.shadowRadius = 5
    }
    
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let frame = self.bounds.insetBy(dx: -20, dy: 0)
            return frame.contains(point) ? self : nil
        }
}
