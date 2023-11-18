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
