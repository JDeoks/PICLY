//
//  ViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var searchTagStackView: UIStackView!
    @IBOutlet var searchTagTextField: UITextField!
    @IBOutlet var searchCancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
    }
    
    func initUI() {
        // 검색 바
        searchTagStackView.layer.cornerRadius = 4
        searchTagTextField.delegate = self
        searchCancelButton.isHidden = true
    }
    
    func action() {
        searchCancelButton.rx.tap
            .subscribe { _ in
                self.searchCancelButton.isHidden = true
                self.searchTagTextField.text = ""
                self.searchTagTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.1, delay: 0, options:.curveEaseOut ,animations: {
                    self.titleStackView.isHidden = false
                })
            }
    }

}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1, delay: 0, options:.curveEaseOut ,animations: {
            self.titleStackView.isHidden = true
            self.searchCancelButton.isHidden = false
        })
    }
    
}
