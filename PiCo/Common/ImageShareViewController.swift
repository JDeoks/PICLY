//
//  ImageShareViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/21/23.
//

import UIKit

///  이미지 공유하는 VC가 상속하는 클래스
class ImageShareViewController: UIViewController {
    
    /// 올린 포토의 URL
    var photoURL: URL?
    
    /// 로딩 표시 인디케이터
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
    
    ///
    // TODO: 핸들러 추가해서 공유익스텐션일경우와 그냥 prese
    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            UIPasteboard.general.url = self.photoURL
            self.dismiss(animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "창 닫기", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        sheet.addAction(loginAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true)
    }
}
