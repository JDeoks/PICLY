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
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    let loginManager = LoginManager()
    var shouldShowOnboarding = true
    
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))

    @IBOutlet var signInWithGoogleButtonView: UIView!
    @IBOutlet var signInWithAppleButtonView: UIView!
    @IBOutlet var googleLogoImageView: UIImageView!
    @IBOutlet var continueWithEmailButtonView: UIView!
    @IBOutlet var continueWithEmailLabel: UILabel!
    @IBOutlet var termsOfUseTextView: UITextView!
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        super.viewDidLoad()
        
        print("애널리틱스 로그 찍음")
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title!)",
            AnalyticsParameterItemName: title!,
            AnalyticsParameterContentType: "cont",
        ])
        
        initUI()
        action()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserManager.shared.hasCompletedInitialLaunch() == false && shouldShowOnboarding == true {
            SceneManager.shared.presentOnboardingVC(vc: self, animated: false)
            shouldShowOnboarding = false
        }
    }
    
    func initUI() {
        // navigation
        self.navigationController?.navigationBar.isHidden = true

        // signInWithGoogleButtonView
        signInWithGoogleButtonView.layer.cornerRadius = 4
        
        // signInWithAppleButtonView
        signInWithAppleButtonView.layer.cornerRadius = 4
        
        // googleLogoImageView
        googleLogoImageView.layer.cornerRadius = 2

        // continueWithEmailLabel
        let attributedString = NSMutableAttributedString(string: continueWithEmailLabel.text!)
        attributedString.addAttribute(
            NSAttributedString.Key.underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        continueWithEmailLabel.attributedText = attributedString
        
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
                self.loginManager.startSignInWithGoogleFlow(vc: self)
            })
            .disposed(by: disposeBag)
        
        signInWithAppleButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                HapticManager.shared.triggerImpact()
                self.view.addSubview(self.loadingView)
                self.loginManager.startSignInWithAppleFlow(vc: self)
            })
            .disposed(by: disposeBag)
        
        continueWithEmailButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                SceneManager.shared.pushEmailVC(vc: self, state: .signIn)
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        loginManager.signInProcessDone
            .subscribe { _ in
                print("signInProcessDone")
                self.loadingView.removeFromSuperview()
                SceneManager.shared.setMainTabVCAsRoot(animated: true)
                UserManager.shared.setHasCompletedInitialLaunch(true)
            }
            .disposed(by: disposeBag)
        
        loginManager.signInFailed
            .subscribe { _ in
                self.loadingView.removeFromSuperview()
            }
            .disposed(by: disposeBag)
    }

}
