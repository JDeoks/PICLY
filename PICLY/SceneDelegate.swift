//
//  SceneDelegate.swift
//  PICLY
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("\(type(of: self)) - \(#function)")
        
        guard let _ = (scene as? UIWindowScene) else { return }

        if isUserLoggedIn() && UserManager.shared.hasCompletedInitialLaunch(){
            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController

            window?.rootViewController = mainVC
        } else {
            let SignInNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInNavController") as? UINavigationController

            window?.rootViewController = SignInNavVC
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

// MARK: - 시작화면 로직
extension SceneDelegate {

    func isUserLoggedIn() -> Bool {
        print("\(type(of: self)) - \(#function)")

        do {
            try Auth.auth().useUserAccessGroup("group.com.Deok.PICLY.Share")
        } catch let error {
            print("Error setting user access group: \(error)")
            return false
        }

        return Auth.auth().currentUser != nil
    }
    
}
