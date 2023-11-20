//
//  UploadViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import RxKeyboard
import SnapKit

class UploadViewController: UIViewController {
    
    /// 서버에 저장된 사진 URL
    var photoURL: URL?
    
    let disposeBag = DisposeBag()
    
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
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var guideStackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var datePicker: UILabel!
    
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
        // activityIndicator
        view.addSubview(self.activityIndicator)
    }
    
    @objc func imageContainerViewTapped(_ sender: UITapGestureRecognizer) {
        print("\(sender.view!.tag) 클릭됨")
    }
    
    func action() {
        closeButton.rx.tap
            .subscribe { _ in
            self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .subscribe { _ in
                print("hello")
                self.activityIndicator.startAnimating()
                self.showUploadFinishedAlert()
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

extension UploadViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){ 
        self.view.endEditing(true)
    }
    
}
