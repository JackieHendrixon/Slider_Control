//
//  RangeTableViewCell.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class RangeTableViewCell: UITableViewCell {

    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        toTextField.accessibilityIdentifier = "toTextField"
        toTextField.textColor = UIColor.white
        toTextField.layer.borderColor = Settings.orangeColor.cgColor
        toTextField.layer.borderWidth = 1
        toTextField.layer.cornerRadius = 5
        
        fromTextField.accessibilityIdentifier = "fromTextField"
        fromTextField.textColor = UIColor.white
        fromTextField.layer.borderColor = Settings.orangeColor.cgColor
        fromTextField.layer.borderWidth = 1
        fromTextField.layer.cornerRadius = 5
        
        backgroundColor = contentView.backgroundColor;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
