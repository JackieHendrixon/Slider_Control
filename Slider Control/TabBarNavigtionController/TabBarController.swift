//
//  TabBarController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class TabBarController: UITabBarController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Sets the tabBar images color 
        tabBar.tintColor = UIColor.appOrange
    }
}
