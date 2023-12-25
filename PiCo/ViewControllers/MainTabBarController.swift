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

class MainTabBarController: UITabBarController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        
        super.viewDidLoad()
        initUI()
        initData()
        bind()
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "SecondText")
        self.tabBar.items?[0].title = "내 앨범"
        self.tabBar.items?[1].title = "설정"
    }
    
    func initData() {
        ConfigManager.shared.fetchRemoteConfig()
        LoginManager.shared.fetchUserAuth()
        LoginManager.shared.getUserModelFromServer()
    }
    
    func bind() {
        LoginManager.shared.fetchUserAuthFailed
            .subscribe { _ in
                LoginManager.shared.signOut()
                SceneManager.shared.setSignInVCAsRoot(animated: false)
            }
            .disposed(by: disposeBag)
    }
    
}
