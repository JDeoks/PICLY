//
//  MainTabBarController.swift
//  PiCo
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
        initUI()
        initData()
        bind()

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
    
    func initData() {
        ConfigManager.shared.fetchRemoteConfig()
        UserManager.shared.fetchUserAuth()
        UserManager.shared.getUserModelFromServer()
    }
    
    func bind() {
        UserManager.shared.fetchUserAuthFailed
            .subscribe { _ in
                print("fetchUserAuthFailed")
                UserManager.shared.signOut()
                SceneManager.shared.setSignInVCAsRoot(animated: false)
            }
            .disposed(by: disposeBag)
    }
    
}
