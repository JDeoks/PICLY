//
//  SceneManager.swift
//  PiCo
//
//  Created by JDeoks on 12/19/23.
//

import Foundation
import UIKit

class SceneManager {
    
    static let shared = SceneManager()
    private init() { }
    
    enum Scene: String {
        case signInNav = "SignInNavController"
        case signIn = "SignInViewController"
        case onboarding = "OnboardingViewController"
        case email = "EmailViewController"
        case mainTab = "MainTabBarController"
        case myAlbum = "MyAlbumsViewController"
        case detail = "DetailViewController"
        case upload = "UploadViewController"
        case edit = "EditViewController"
        case setting = "SettingViewController"
        case account = "AcountViewController"
        case web = "WebViewController"
    }
    
    private func getVC(scene: Scene) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: scene.rawValue)
    }
    
    func presentOnboardingVC(vc: UIViewController, animated: Bool) {
        print("\(type(of: self)) - \(#function)")
        
        let onboardingVC = getVC(scene: .onboarding) as! OnboardingViewController
        onboardingVC.modalPresentationStyle = .overFullScreen
        onboardingVC.modalTransitionStyle = .crossDissolve
        vc.present(onboardingVC, animated: animated)
    }
    
    func pushEmailVC(vc: UIViewController, state: EmailVCState) {
        print("\(type(of: self)) - \(#function)")
        
        let emailVC = getVC(scene: .email) as! EmailViewController
        emailVC.setData(state: state)
        vc.navigationController?.pushViewController(emailVC, animated: true)
    }
    
    func pushDetailVC(vc: UIViewController, album: AlbumModel) {
        print("\(type(of: self)) - \(#function)")
        
        let detailVC = getVC(scene: .detail) as! DetailViewController
        detailVC.album = album
        detailVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func presentUploadVC(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        
        let uploadVC = getVC(scene: .upload)
        uploadVC.modalPresentationStyle = .overFullScreen
        vc.present(uploadVC, animated: true)
    }

    func pushAccountVC(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        
        let accountVC = getVC(scene: .account)
        accountVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(accountVC, animated: true)
    }
    
    func presentWebVC(vc: UIViewController, url: URL) {
        print("\(type(of: self)) - \(#function)")
        
        let webVC = getVC(scene: .web) as! WebViewController
        webVC.pageURL = url
        vc.present(webVC, animated: true)
    }
    
    // TODO: - 최적화 필요 뷰 컨트롤러 계속 생성함
    func setSignInVCAsRoot(animated: Bool) {
        let signInNavVC = getVC(scene: .signInNav) as! UINavigationController

        let window = UIApplication.shared.getWindow()
        // 현재 루트 뷰 컨트롤러의 스냅샷 가져오기
        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
            return
        }
        // 새 루트 뷰 컨트롤러 설정
        window.rootViewController = signInNavVC
        if animated {
            // 스냅샷을 새 루트 뷰 컨트롤러 위에 추가
            signInNavVC.view.addSubview(snapshot)
            // 애니메이션을 통해 스냅샷을 서서히 사라지게 함
            UIView.animate(withDuration: 0.5, animations: {
                snapshot.layer.opacity = 0
            }) { _ in
                snapshot.removeFromSuperview()
            }
        }
    }
    
    func setMainTabVCAsRoot(animated: Bool) {
        let window = UIApplication.shared.getWindow()

        let mainTabVC = getVC(scene: .mainTab)
        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
            return
        }
        window.rootViewController = mainTabVC
        if animated {
            mainTabVC.view.addSubview(snapshot)
            UIView.animate(withDuration: 0.5, animations: {
                snapshot.layer.opacity = 0
            }) { _ in
                snapshot.removeFromSuperview()
            }
        }
    }

}
