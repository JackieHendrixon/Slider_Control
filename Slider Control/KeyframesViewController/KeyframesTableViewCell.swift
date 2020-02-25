//
//  KeyframesTableViewCell.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class KeyframesTableViewCell : UITableViewCell {
    
    // MARK: - Properties
    var keyframe: Keyframe? {
        didSet{
            updateData()
        }
    }
    
    @IBOutlet weak var timecodeValueLabel: UILabel!
    @IBOutlet weak var xValueLabel: UILabel!
    @IBOutlet weak var panValueLabel: UILabel!
    @IBOutlet weak var tiltValueLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .didChangeTimecodeFormat, object: nil)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = contentView.backgroundColor;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func updateData() {
        timecodeValueLabel.text = keyframe?.timecode.toString
        if let text = keyframe?.parameters.x {
            xValueLabel.text = String(text)
        }
        if let text = keyframe?.parameters.pan {
            panValueLabel.text =  String(text)
        }
        if let text = keyframe?.parameters.tilt {
            tiltValueLabel.text =  String(text)
        }
    }
}
