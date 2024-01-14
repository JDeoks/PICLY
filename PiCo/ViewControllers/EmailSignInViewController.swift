//
//  EmailSignInViewController.swift
//  PiCo
//
//  Created by JDeoks on 1/13/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

class EmailSignInViewController: UIViewController {
    
    private var emailSignInVCState: EmailSignInVCState = .signIn
    private var keyboardHeight: CGFloat = 40

    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))

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
        print("\(type(of: self)) - \(#function): \(emailSignInVCState)")
        super.viewDidLoad()
        
        initUI()
        initData()
        action()
        bind()
    }
    
    func setData(state: EmailSignInVCState) {
        print("\(type(of: self)) - \(#function)")

        emailSignInVCState = state
    }
    
    private func initUI() {
        // scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        
        // emailTextStackView
        emailTextStackView.layer.cornerRadius = 4
        
        // emailTextField
        emailTextField.delegate = self
        
        // passwordTextStackView
        passwordTextStackView.layer.cornerRadius = 4
        
        // passwordTextField
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        // siginInButton
        siginInButton.layer.cornerRadius = 4
    }
    
    private func initData() {
        switch emailSignInVCState {
        case .signIn:
            pageTitleLabel.text = "로그인"
        case .signUp:
            pageTitleLabel.text = "회원가입"
            moveToSignupButton.isHidden = true
            siginInButton.setTitle("회원가입", for: .normal)
        }
    }
    
    private func action() {
        backButton.rx.tap
            .subscribe { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 회원가입 페이지 이동 버튼
        moveToSignupButton.rx.tap
            .subscribe { _ in
                SceneManager.shared.pushEmailVC(vc: self, state: .signUp)
            }
            .disposed(by: disposeBag)
        
        // 비밀번호 보이기 토글 버튼
        pwVisibleImageViewButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                if self.passwordTextField.isSecureTextEntry {
                    self.pwVisibleImageViewButton.image = UIImage(systemName: "eye")
                    self.passwordTextField.isSecureTextEntry = false
                } else {
                    self.pwVisibleImageViewButton.image = UIImage(systemName: "eye.slash")
                    self.passwordTextField.isSecureTextEntry = true
                }
            }
            .disposed(by: disposeBag)
        
        // 로그인 & 회원가입 버튼
        siginInButton.rx.tap
            .subscribe { _ in
                print("siginInButton: \(self.emailSignInVCState)")
                self.view.addSubview(self.loadingView)
                switch self.emailSignInVCState {
                case .signIn:
                    self.signIn()
                case .signUp:
                    self.signUp()
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
                strongSelf.keyboardHeight = keyboardVisibleHeight == 0 ? 40 : keyboardVisibleHeight
                UIView.animate(withDuration: 0, delay: 0.05, options: .curveEaseInOut, animations: {
                    strongSelf.signInContainerStackView.snp.updateConstraints { make in
                        make.bottom.equalToSuperview().inset(keyboardVisibleHeight).priority(1000)
                        
                    }
                    strongSelf.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
    
    func bind() {
        LoginManager.shared.signInFailed
            .subscribe { errorMsg in
                self.loadingView.removeFromSuperview()
                self.showToast(message: errorMsg, keyboardHeight: self.keyboardHeight)
            }
            .disposed(by: disposeBag)
        
        LoginManager.shared.createUserWithEmailFailed
            .subscribe { errorMsg in
                self.loadingView.removeFromSuperview()
                self.showToast(message: errorMsg, keyboardHeight: self.keyboardHeight)
            }
            .disposed(by: disposeBag)
    }
    
    func signIn() {
        print("\(type(of: self)) - \(#function)")

        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        LoginManager.shared.performLogin(email: email, password: password)
    }
    
    func signUp() {
        print("\(type(of: self)) - \(#function)")

        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        LoginManager.shared.createUserWithEmail(email: email, password: password)
    }
    
}

// MARK: - UITextField
extension EmailSignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
}

// MARK: - UIScrollView
extension EmailSignInViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    
}
