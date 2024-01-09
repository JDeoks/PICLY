//
//  SignInViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/30/23.
//

import UIKit
import GoogleSignIn
import RxSwift
import RxCocoa
import RxGesture
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    var shouldShowOnboarding = true
    
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))

    @IBOutlet var signInWithGoogleButtonView: UIView!
    @IBOutlet var signInWithAppleButtonView: UIView!
    @IBOutlet var googleLogoImageView: UIImageView!
    @IBOutlet var termsOfUseTextView: UITextView!
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        super.viewDidLoad()
        
        initUI()
        action()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldShowOnboarding {
            SceneManager.shared.presentOnboardingVC(vc: self, animated: false)
            shouldShowOnboarding = false
        }
    }
    
    func initUI() {
        // signInWithGoogleButtonView
        signInWithGoogleButtonView.layer.cornerRadius = 4
        
        // signInWithAppleButtonView
        signInWithAppleButtonView.layer.cornerRadius = 4
        
        // googleLogoImageView
        googleLogoImageView.layer.cornerRadius = 2
        
        // termsOfUseTextView
        let linkedText = NSMutableAttributedString(attributedString: termsOfUseTextView.attributedText)
        let termOfUseLink = linkedText.setAsLink(
            textToFind: "이용약관",
            linkURL: "https://jdeoks.notion.site/5cc8688a9432444eaad7a8fdc4e4e38a?pvs=4"
        )
        let privacyPolicyLink = linkedText.setAsLink(
            textToFind: "개인정보처리방침",
            linkURL: "https://jdeoks.notion.site/bace573d0a294bdeae4a92464448bcac?pvs=4"
        )
        if termOfUseLink || privacyPolicyLink {
            termsOfUseTextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
    }
    
    func action() {
        signInWithGoogleButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                HapticManager.shared.triggerImpact()
                self.view.addSubview(self.loadingView)
                LoginManager.shared.startSignInWithGoogleFlow(vc: self)
            })
            .disposed(by: disposeBag)
        
        signInWithAppleButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                HapticManager.shared.triggerImpact()
                self.view.addSubview(self.loadingView)
                LoginManager.shared.startSignInWithAppleFlow(vc: self)
            })
            .disposed(by: disposeBag)
    }
    
    func bind() {
        LoginManager.shared.signInWithCredentialDone
            .subscribe { _ in
                self.loadingView.removeFromSuperview()
                SceneManager.shared.setMainTabVCAsRoot(animated: true)
            }
            .disposed(by: disposeBag)
        
        LoginManager.shared.signInFailed
            .subscribe { _ in
                self.loadingView.removeFromSuperview()
            }
            .disposed(by: disposeBag)
    }
    
}
