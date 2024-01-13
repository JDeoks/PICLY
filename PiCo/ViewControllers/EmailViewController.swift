//
//  EmailViewController.swift
//  PiCo
//
//  Created by JDeoks on 1/13/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

class EmailViewController: UIViewController {
    
    
    private var emailVCState: EmailVCState = .signIn
    private var isPasswordVisible = false
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var pageTitleLabel: UILabel!
    @IBOutlet var moveToSignupButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var emailTextStackView: UIStackView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextStackView: UIStackView!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var pwVisibleImageViewButton: UIImageView!
    @IBOutlet var siginInButton: UIButton!
    @IBOutlet var signInContainerStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
        print(emailTextField.frame.size)
    }
    
    func setData(state: EmailVCState) {
        emailVCState = state
    }
    
    private func initUI() {
        // scrollView
        scrollView.alwaysBounceVertical = true
        
        // emailTextStackView
        emailTextStackView.layer.cornerRadius = 4
        
        // emailTextField
        emailTextField.delegate = self
        
        // passwordTextStackView
        passwordTextStackView.layer.cornerRadius = 4
        
        // passwordTextField
        passwordTextField.delegate = self
        
        // siginInButton
        siginInButton.layer.cornerRadius = 4
    }
    
    private func initData() {
        switch emailVCState {
        case .signIn:
            pageTitleLabel.text = "로그인"
        case .signUp:
            pageTitleLabel.text = "회원가입"
            moveToSignupButton.isHidden = true
            siginInButton.setTitle("회원가입", for: .normal)
        }
    }
    
    private func action() {
        moveToSignupButton.rx.tap
            .subscribe { _ in
                SceneManager.shared.pushEmailVC(vc: self, state: .signUp)
            }
            .disposed(by: disposeBag)
        
        pwVisibleImageViewButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                if self.isPasswordVisible {
                    self.pwVisibleImageViewButton.image = UIImage(systemName: "eye.slash")
                    self.isPasswordVisible = false
                } else {
                    self.pwVisibleImageViewButton.image = UIImage(systemName: "eye")
                    self.isPasswordVisible = true
                }
            }
            .disposed(by: disposeBag)
        
        siginInButton.rx.tap
            .subscribe { _ in
                switch self.emailVCState {
                case .signIn:
                    break
                    // TODO: 로그인 로직
                case .signUp:
                    break
                    // TODO: 회원가입 로직
                }
            }
            .disposed(by: disposeBag)
        
        // 키보드 툴바
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let strongSelf = self else {
                    return
                }
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    strongSelf.signInContainerStackView.snp.updateConstraints { make in
                        make.bottom.equalToSuperview().inset(keyboardVisibleHeight).priority(1000)
                        
                    }
                    strongSelf.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
    }
    
}


// MARK: - UITextField
extension EmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
}
