//
//  EditViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import RxKeyboard
import SnapKit

class EditViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet var backButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var tagTextField: UITextField!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageView: UILabel!
    @IBOutlet var guideStackView: UIStackView!
    @IBOutlet var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
        print(scrollView.frame)
    }
    
    func initUI() {
        imageContainerView.layer.cornerRadius = 4
        imageView.layer.cornerRadius = 4
        // imageContainerView
        imageContainerView.tag = 1
        //클릭 가능하도록 설정
        self.imageContainerView.isUserInteractionEnabled = true
        //제스쳐 추가
        self.imageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageContainerViewTapped)))
        // 태그 스택뷰
        inputTagStackView.layer.cornerRadius = 4
        // datePicker
        datePicker.tintColor = UIColor(named: "HighlightBlue")
        scrollView.delegate = self
    }
    
    @objc func imageContainerViewTapped(_ sender: UITapGestureRecognizer) {
        print("\(sender.view!.tag) 클릭됨")
    }
    
    func action() {
        backButton.rx.tap
            .subscribe { _ in
            self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        // TODO: 질문 RxKeyboard 적용 안됨
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { keyboardVisibleHeight in
                print("rx키보드")
                print(keyboardVisibleHeight)  // 346.0
                self.scrollView.snp.updateConstraints { make in
                    UIView.animate(withDuration: 1) {
                        make.bottom.equalToSuperview().inset(keyboardVisibleHeight)
                        print(self.scrollView.frame)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

}

extension EditViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){ self.view.endEditing(true)
    }
    
}
