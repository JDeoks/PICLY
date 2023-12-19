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
        case detail = "DetailViewController"
    }
    
    private func getVC(scene: Scene) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: scene.rawValue)
    }
    
    func pushDetailVC(vc: UIViewController) {
        let detailVC = getVC(scene: .detail)
        detailVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }

}
