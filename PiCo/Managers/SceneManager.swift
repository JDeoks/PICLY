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
        case signIn = "SignInViewController"
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
    
    func pushDetailVC(vc: UIViewController) {
        let detailVC = getVC(scene: .detail)
        detailVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func presentUploadVC(vc: UIViewController) {
        let uploadVC = getVC(scene: .upload)
        uploadVC.modalPresentationStyle = .overFullScreen
        vc.present(uploadVC, animated: true)
    }

    func pushAccountVC(vc: UIViewController) {
        let accountVC = getVC(scene: .account)
        accountVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(accountVC, animated: true)
    }
    
    func presentWebVC(vc: UIViewController, url: URL) {
        let webVC = getVC(scene: .web) as! WebViewController
        webVC.pageURL = url
        vc.present(webVC, animated: true)
    }

}
