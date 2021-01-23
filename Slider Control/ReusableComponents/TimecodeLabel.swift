//
//  Timecode.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class TimecodeLabel: UILabel {
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.font = UIFont.monospacedDigitSystemFont(ofSize: self.font.pointSize, weight: UIFont.Weight.medium)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel), name: .didUpdateCurrentTimecode, object: nil)
      
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel), name: .didChangeTimecodeFormat, object: nil)
        updateLabel()
    }
    
//    override init(frame: CGRect) {
//        <#code#>
//    }
    
    // MARK: - Private functions
    
    @objc private func updateLabel() {
        self.text = CurrentTimecode.current.toString
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: -20, dy: 0)
        return frame.contains(point) ? self : nil
    }
    
}


