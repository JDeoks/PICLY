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
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
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
