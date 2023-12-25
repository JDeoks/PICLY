//
//  MainTabBarController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import FirebaseAuth
import RxSwift

class MainTabBarController: UITabBarController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        
        super.viewDidLoad()
        initUI()
        bind()
        LoginManager.shared.fetchUserAuth()
        LoginManager.shared.getUserModelFromServer()
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "SecondText")
        self.tabBar.items?[0].title = "내 앨범"
        self.tabBar.items?[1].title = "설정"
    }
    
    func bind() {
        LoginManager.shared.fetchUserAuthFailed
            .subscribe { _ in
                LoginManager.shared.signOut()
                self.setOnboardingVCAsRoot()
            }
            .disposed(by: disposeBag)
    }
    
    func setOnboardingVCAsRoot() {
        print("\(type(of: self)) - \(#function)")

        let window = UIApplication.shared.getWindow()
        // 넘어갈 화면
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        // 새 루트 뷰 컨트롤러 설정
        window.rootViewController = signInVC
    }

}
