//
//  MainTabBarController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
    }

}
