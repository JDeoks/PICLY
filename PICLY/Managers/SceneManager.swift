//
//  SceneManager.swift
//  PICLY
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
        case email = "EmailSignInViewController"
        case mainTab = "MainTabBarController"
        case myAlbum = "MyAlbumsViewController"
        case detail = "DetailViewController"
        case imageViewer = "ImageViewerViewController"
        case upload = "UploadViewController"
        case edit = "EditViewController"
        case setting = "SettingViewController"
        case account = "AcountViewController"
        case web = "WebViewController"
    }
    
    private func getVC(scene: Scene) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: scene.rawValue)
    }
    
    // MARK: - signInNav
    /// 탈퇴시 실행하는 재로그인에 사용
    func presentSignInNavVC(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")

        let signInNavVC = getVC(scene: .signInNav) as! UINavigationController
        vc.present(signInNavVC, animated: true)
    }
    
    // MARK: - onboardingVC
    func presentOnboardingVC(vc: UIViewController, animated: Bool) {
        print("\(type(of: self)) - \(#function)")
        
        let onboardingVC = getVC(scene: .onboarding) as! OnboardingViewController
        onboardingVC.modalPresentationStyle = .overFullScreen
        onboardingVC.modalTransitionStyle = .crossDissolve
        vc.present(onboardingVC, animated: animated)
    }
    
    // MARK: - emailVC
    func pushEmailVC(vc: UIViewController, state: EmailSignInVCState) {
        print("\(type(of: self)) - \(#function)")
        
        let emailVC = getVC(scene: .email) as! EmailSignInViewController
        emailVC.setData(state: state)
        vc.navigationController?.pushViewController(emailVC, animated: true)
    }
    
    /// 재인증에 사용
    func presentEmailVC(vc: UIViewController, state: EmailSignInVCState){
        print("\(type(of: self)) - \(#function)")
        let vc = vc as! AcountViewController
        let emailVC = getVC(scene: .email) as! EmailSignInViewController
        emailVC.setData(state: state)
        emailVC.loginManager = vc.loginManager
        vc.present(emailVC, animated: true)
    }
    
    // MARK: - detailVC
    func pushDetailVC(vc: UIViewController, album: AlbumModel) {
        print("\(type(of: self)) - \(#function)")
        
        let detailVC = getVC(scene: .detail) as! DetailViewController
        detailVC.detailViewModel.album = album
        detailVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - imageViewerVC
    func presentImageViewerVC(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        
        let imageViewerVC = getVC(scene: .imageViewer)
        imageViewerVC.modalPresentationStyle = .overFullScreen
        vc.present(imageViewerVC, animated: true)
    }
    
    // MARK: - uploadVC
    func presentUploadVC(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        
        let uploadVC = getVC(scene: .upload)
        uploadVC.modalPresentationStyle = .overFullScreen
        vc.present(uploadVC, animated: true)
    }

    // MARK: - accountVC
    func pushAccountVC(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        
        let accountVC = getVC(scene: .account)
        accountVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(accountVC, animated: true)
    }
    
    // MARK: - webVC
    func presentWebVC(vc: UIViewController, url: URL) {
        print("\(type(of: self)) - \(#function)")
        
        let webVC = getVC(scene: .web) as! WebViewController
        webVC.pageURL = url
        vc.present(webVC, animated: true)
    }
    
    // MARK: - 루트뷰 컨트롤러 설정
    // TODO: - 최적화 필요 뷰 컨트롤러 계속 생성함
    func setSignInNavVCAsRoot(animated: Bool) {
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
