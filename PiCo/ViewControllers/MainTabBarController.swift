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
        fetchUserInfo()
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "SecondText")
    }
    
    /// 유저 정보 갱신. 유효하지 않으면 리스너가 rootVC 온보딩으로 바꿈
    func fetchUserInfo() {
        print("MainTabBarController - fetchUserInfo()")

        if let user = Auth.auth().currentUser {
            // 서버에서 사용자 상태 갱신
            user.reload { error in
                if let error = error {
                    print("사용자 상태 갱신 실패: \(error.localizedDescription)")
                    self.resetAuthenticationState()
                } else {
                    print("MainTabBarController - fetchUserInfo()")

                    print("현재 로그인된 사용자 정보:")
                    print("UID: \(user.uid)")
                    print("이메일: \(String(describing: user.email))")
                }
            }
        } else {
            resetAuthenticationState()
            print("currentUser 없음")
        }
    }
    
    func resetAuthenticationState() {
        print("MainTabBarController - resetAuthenticationState()")

        do {
            try Auth.auth().signOut()
            // 로그아웃 성공 후 필요한 작업 수행, 예를 들어 루트 뷰 컨트롤러 변경
//           TODO: - switchToOnboarding()
            setOnboardingVCAsRoot()
        } catch let signOutError {
            print("Firebase 인증 초기화 실패: \(signOutError)")
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
