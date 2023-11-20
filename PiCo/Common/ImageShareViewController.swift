//
//  ImageShareViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/21/23.
//

import UIKit

class ImageShareViewController: UIViewController {
    
    var photoURL: URL?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
    
        activityIndicator.color = UIColor(named: "SecondText")
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        // activityIndicator는 멈춰있을 때 isHidden 됨
        activityIndicator.stopAnimating()
        
        return activityIndicator
    }()
    
    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            UIPasteboard.general.url = self.photoURL
        })
        
        let cancelAction = UIAlertAction(title: "창 닫기", style: .cancel)
        
        sheet.addAction(loginAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true)
    }
}
