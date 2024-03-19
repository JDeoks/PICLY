//
//  MainTabBarController.swift
//  PICLY
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import FirebaseAuth
import FirebaseRemoteConfig
import SkeletonView

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        
        super.viewDidLoad()
        //initUI()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController !== viewController {
            HapticManager.shared.triggerImpact()
        }
        return true
    }
    
    func initUI() {
        self.delegate = self
        self.tabBar.tintColor = ColorManager.shared.highlightBlue
        self.tabBar.unselectedItemTintColor = ColorManager.shared.secondText
        self.tabBar.items?[0].title = "내 앨범"
        self.tabBar.items?[1].title = "설정"
    }

    deinit {
        print("\(type(of: self)) - \(#function)")
    }
}
