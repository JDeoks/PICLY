//
//  UploadViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift

class UploadViewController: UIViewController {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var guideStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
    }
    
    func initUI() {
        imageContainerView.layer.cornerRadius = 4
        imageView.layer.cornerRadius = 4
        
        // imageContainerView
        imageContainerView.tag = 1
        //클릭 가능하도록 설정
        self.imageContainerView.isUserInteractionEnabled = true
        //제쳐스 추가
        self.imageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageContainerViewTapped)))
    }
    
    @objc func imageContainerViewTapped(_ sender: UITapGestureRecognizer) {
        print("\(sender.view!.tag) 클릭됨")
    }
    
    func action() {
        closeButton.rx.tap.subscribe { _ in
            self.dismiss(animated: true)
        }
    }

}
