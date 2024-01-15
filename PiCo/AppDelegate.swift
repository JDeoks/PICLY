//
//  AppDelegate.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    override init() {
        super.init()
        Thread.sleep(forTimeInterval: 0.3)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
}

//
extension AppDelegate {
//    
//    func setRootVC() {
//        print("\(type(of: self)) - \(#function)")
//        
//        // 현재 로그인된 사용자 가져오기
//        if let user = Auth.auth().currentUser {
//            // 서버에서 사용자 상태 갱신
//            user.reload { error in
//                if let error = error {
//                    //TODO: 오류 alert
//                    self.showMainScreen()
//                    print("사용자 상태 갱신 실패: \(error.localizedDescription)")
//                } else {
//                    self.showMainScreen()
//                }
//            }
//        } else {
//            showMainScreen()
//        }
//           
//    }
//    
//    func showMainScreen() {
//        print("\(type(of: self)) - \(#function)")
//        
//        let mainTabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
//        print(1)
//        
//        let window = UIApplication.shared.getWindow()
//        window.rootViewController = mainTabBarVC
//    }
//    
//    func showOnboarding() {
//        print("\(type(of: self)) - \(#function)")
//        
//        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//        let window = UIApplication.shared.getWindow()
//        window.rootViewController = signInVC
//    }

}

