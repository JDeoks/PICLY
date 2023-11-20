//
//  UIViewController+Extensions.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit

extension UIViewController {

    // 토스트
    func showToast(message : String) {
        let toastwidth = 200
        let toastHeight = 35
        let toastLabel = UILabel(frame: CGRect(x: Int(self.view.frame.size.width)/2 - toastwidth / 2, y: Int(self.view.frame.size.height)-100, width: toastwidth, height: toastHeight))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        toastLabel.textColor = UIColor(named: "mainText")
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = CGFloat(toastHeight / 2);
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2, delay: 0.1, options: .curveEaseIn, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIViewController {

    // 키보드 숨기기
    func hideKeyboardByTouchEvent() {
        hideKeyboardWhenTappedAround()
        hideKeyboardWhenScrolled()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboardWhenScrolled() {
        let scroll = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(scroll)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UIViewController {
    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            print("yes 클릭")
        })
        
        let cancelAction = UIAlertAction(title: "창 닫기", style: .cancel)
        
        sheet.addAction(loginAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true)
    }
}
