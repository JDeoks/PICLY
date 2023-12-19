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
        print("MainTabBarController - viewDidLoad")
        
        super.viewDidLoad()
        initUI()
        bind()
        LoginManager.shared.fetchAccount()
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "SecondText")
    }
    
    func bind() {
        LoginManager.shared.fetchAccountFailed
            .subscribe { _ in
                self.resetAuthenticationState()
                self.setOnboardingVCAsRoot()
            }
            .disposed(by: disposeBag)
        
    }
    
    // 인증 정보 리셋후 온보딩으로
    func resetAuthenticationState() {
        print("MainTabBarController - resetAuthenticationState()")

        do {
            try Auth.auth().signOut()
        } catch let signOutError {
            // TODO: 인증 오류가 발생했습니다. 앱을 재시작해 주세요 Alert
        }
    }
    
    func setOnboardingVCAsRoot() {
        print("MainTabBarController - setOnboardingVCAsRoot()")

        // window 객체 가져오기
        let scenes: Set<UIScene> = UIApplication.shared.connectedScenes
        let windowScene: UIWindowScene? = scenes.first as? UIWindowScene
        let window: UIWindow? = windowScene!.windows.first
        // 넘어갈 화면
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        // 새 루트 뷰 컨트롤러 설정
        window?.rootViewController = signInVC
    }

}
