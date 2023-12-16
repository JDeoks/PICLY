//
//  MainTabBarController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        try! Auth.auth().signOut()
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "SecondText")
    }

}
