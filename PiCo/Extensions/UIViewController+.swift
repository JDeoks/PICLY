//
//  UIViewController+.swift
//  PiCo
//
//  Created by JDeoks on 1/7/24.
//

import UIKit

// MARK: - ToastAlert
extension UIViewController {

    func showToast(message : String) {
        let toastLabel = UILabel()
        toastLabel.numberOfLines = 2
        toastLabel.backgroundColor = ColorManager.shared.highlightBlue.withAlphaComponent(0.9)
        toastLabel.textColor = .black
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 8.7
        toastLabel.clipsToBounds = true

        self.view.addSubview(toastLabel)

        toastLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().multipliedBy(0.85) // 하단에서 80% 위치
                make.height.greaterThanOrEqualTo(35)
                make.width.greaterThanOrEqualTo(200) // 최소 너비: 200
                make.width.lessThanOrEqualTo(self.view.snp.width).offset(-40) // 화면 너비에 여백을 두어 최대 너비 설정
            }

        // 애니메이션
        UIView.animate(withDuration: 2, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// MARK: - UITextField
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
