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
        // 현재 로그인된 사용자 가져오기
        if let user = Auth.auth().currentUser {
            // 서버에서 사용자 상태 갱신
            user.reload { error in
                if let error = error {
                    print("사용자 상태 갱신 실패: \(error.localizedDescription)")
                } else {
                    // 갱신된 사용자 정보 출력
                    print("현재 로그인된 사용자 정보:")
                    print("UID: \(user.uid)")
                    print("이메일: \(String(describing: user.email))")
                    print("providerData: \(user.providerData)")
                    // 기타 필요한 정보 출력 가능
                }
            }
        } else {
            print("현재 로그인된 사용자가 없습니다.")
        }
//        try! Auth.auth().signOut()
    }
    
    func initUI() {
        self.tabBar.tintColor = UIColor(named: "HighlightBlue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "SecondText")
    }

}
