//
//  SwitchSettingsTableViewCell.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var control: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = contentView.backgroundColor;
    }
}
