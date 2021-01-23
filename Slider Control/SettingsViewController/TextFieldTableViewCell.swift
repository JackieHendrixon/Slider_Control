//
//  TextFieldTableViewCell.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.textColor = UIColor.white
        textField.layer.borderColor = UIColor.appOrange.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
       
        backgroundColor = contentView.backgroundColor;
    }
}
