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
        
        
        GlobalTimecode.delegates.append(self)
      
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel), name: .didChangeTimecodeFormat, object: nil)
        updateLabel()
    }
    
    // MARK: - Private functions
    
    @objc private func updateLabel() {
        self.text = GlobalTimecode.current.toString
    }
    
}

extension TimecodeLabel: GlobalTimecodeDelegate {
    func didUpdateGlobalTimecode() {
        updateLabel()
    }
}
