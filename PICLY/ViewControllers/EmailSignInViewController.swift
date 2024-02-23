//
//  EmailSignInViewController.swift
//  PICLY
//
//  Created by JDeoks on 1/13/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

class EmailSignInViewController: UIViewController {
    
    private var emailSignInVCState: EmailSignInVCState = .signIn
    var loginManager = LoginManager()

    let disposeBag = DisposeBag()
    
    private var keyboardHeight: CGFloat = 40
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

    // MARK: - LifeCycles
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
    
    // MARK: - initUI
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
    
    // MARK: - initData
    private func initData() {
        switch emailSignInVCState {
        case .signIn:
            pageTitleLabel.text = "로그인"
            
        case .signUp:
            pageTitleLabel.text = "회원가입"
            moveToSignupButton.isHidden = true
            siginInButton.setTitle("회원가입", for: .normal)
            
        case .reauthentication:
            backButton.isHidden = true
            pageTitleLabel.text = "로그인"
            moveToSignupButton.isHidden = true
            emailTextField.text = UserManager.shared.getCurrentUserModel()?.email
        }
    }
    
    // MARK: - action
    private func action() {
        // 뒤로 가기 버튼
        backButton.rx.tap
            .subscribe { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 회원가입 페이지 이동 버튼
        moveToSignupButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
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
                HapticManager.shared.triggerImpact()
                switch self.emailSignInVCState {
                case .signIn:
                    self.performSignIn()
                case .signUp:
                    self.perFormSignUp()
                case .reauthentication:
                    self.performSignIn()
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
                UIView.animate(withDuration: 0, delay: 0.05, options: .curveEaseOut, animations: {
                    strongSelf.signInContainerStackView.snp.updateConstraints { make in
                        make.bottom.equalToSuperview().inset(keyboardVisibleHeight).priority(1000)
                        
                    }
                    strongSelf.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - bind
    private func bind() {
        loginManager.signInProcessDone
            .subscribe { _ in
                print("\(type(of: self)) - signInProcessDone")
                
                self.loadingView.removeFromSuperview()

                switch self.emailSignInVCState {
                case .signIn:
                    SceneManager.shared.setMainTabVCAsRoot(animated: true)
                    UserManager.shared.setHasCompletedInitialLaunch(true)
                case .signUp:
                    SceneManager.shared.setMainTabVCAsRoot(animated: true)
                    UserManager.shared.setHasCompletedInitialLaunch(true)
                case .reauthentication:
                    return
                }
            }
            .disposed(by: disposeBag)
        
        loginManager.signInFailed
            .subscribe { errorMsg in
                print("\(type(of: self)) - signInFailed")

                self.loadingView.removeFromSuperview()
                self.showToast(message: errorMsg, keyboardHeight: self.keyboardHeight)
            }
            .disposed(by: disposeBag)
        
        loginManager.createUserWithEmailFailed
            .subscribe { errorMsg in
                print("\(type(of: self)) - createUserWithEmailFailed")

                self.loadingView.removeFromSuperview()
                self.showToast(message: errorMsg, keyboardHeight: self.keyboardHeight)
            }
            .disposed(by: disposeBag)
    }
    
    func performSignIn() {
        print("\(type(of: self)) - \(#function)")

        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        self.loginManager.performLogin(email: email, password: password)
    }
    
    func perFormSignUp() {
        print("\(type(of: self)) - \(#function)")

        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        self.loginManager.createUserWithEmail(email: email, password: password)
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
