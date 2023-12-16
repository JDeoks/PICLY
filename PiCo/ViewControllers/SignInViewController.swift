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
    
    let userCollectionRef = Firestore.firestore().collection("User")
    /// Unhashed nonce. 애플로그인 암호화에 사용
    fileprivate var currentNonce: String?
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var signInWithGoogleButtonView: UIView!
    @IBOutlet var signInWithAppleButtonView: UIView!
    @IBOutlet var googleLogoImageView: UIImageView!
    @IBOutlet var termsOfUseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
        getCurrentUser()
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
        let termOfUseLink = linkedText.setAsLink(textToFind: "이용약관", 
                                                 linkURL: "https://jdeoks.notion.site/5cc8688a9432444eaad7a8fdc4e4e38a?pvs=4")
        let privacyPolicyLink = linkedText.setAsLink(textToFind: "개인정보처리방침",
                                                     linkURL: "https://jdeoks.notion.site/bace573d0a294bdeae4a92464448bcac?pvs=4")
        if termOfUseLink || privacyPolicyLink {
            termsOfUseTextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
    }
    
    func action() {
        signInWithGoogleButtonView.rx.tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.startSignInWithGoogleFlow()
                    })
                    .disposed(by: disposeBag)
        
        signInWithAppleButtonView.rx.tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.startSignInWithAppleFlow()
                    })
                    .disposed(by: disposeBag)
    }
    
    func getCurrentUser() {
        // 현재 로그인된 사용자 가져오기
        if let user = Auth.auth().currentUser {
            // 서버에서 사용자 상태 갱신
            user.reload { error in
                if let error = error {
                    print("사용자 상태 갱신 실패: \(error.localizedDescription)")
                } else {
                    // 갱신된 사용자 정보 출력
                    print("현재 로그인된 사용자 정보:")
                    print("UID: \(user.uid)")
                    print("이메일: \(String(describing: user.email))")
                    print("이름: \(String(describing: user.displayName))")
                    // 기타 필요한 정보 출력 가능
                }
            }
        } else {
            print("현재 로그인된 사용자가 없습니다.")
        }
    }
    
    func startSignInWithGoogleFlow() {
        print("SignInViewController - startSignInWithGoogleFlow()")
        
        /// Firebase 프로젝트에 부여되는 고유 식별자. OAuth과정에서 애플리케이션 식별할 때 사용
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("clientID 초기화 실패")
            return
        }
        // Google Sign In 초기설정
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // 구글 로그인 뷰 띄우기, dismiss 됐을 때 만든 credential로 로그인
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                // TODO: 로그인 실패 Alert
                print("구글 signIn 실패: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                // TODO: 로그인 실패 Alert
                print("user 또는 idToken 정보 가져오기 실패")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            // 생성한 credential로 로그인 시도
            signInWithCredential(credential: credential, provider: .google)
        }
    }
    
    func signInWithCredential(credential: AuthCredential, provider: AuthProvider) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                // TODO: 로그인 실패 Alert
                print("파이어베이스 signIn 실패: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user else {
                // TODO: 로그인 실패 Alert
                return
            }

            print("유저:", user.providerID, user.uid, user.displayName, user.email)
            // 첫 로그인 시 User Collection에 Doc 추가
            self.isFirstLogin(user: user) { isFirstLogin in
                if isFirstLogin {
                    print("첫 번째 로그인")
                    self.addUserToDB(user: user, provider: provider)
                } else {
                    print("기존 사용자")
                }
            }
            
        }
    }
    
    /// User Collection에 userID의 Doc이 있는지 검사
    func isFirstLogin(user: User, completion: @escaping (Bool) -> Void) {
        print("SignInViewController - isFirstLogin(user:)")

        let userDocRef = userCollectionRef.document(user.uid)

        userDocRef.getDocument { (document, error) in
            if let error = error {
                print(error)
                return
            }
            // 문서가 존재하면 false 반환
            if let document = document, document.exists {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    /// 유저 Doc 생성
    func addUserToDB(user: User, provider: AuthProvider) {
        print("SignInViewController - addUserToDB(user:)")

        userCollectionRef.document(user.uid).setData([
            "creationTime": Timestamp(date: Date()),
            "authProvider": provider.description,
            "email": user.email ?? "nil",
            "albumIDs": []
        ]){ err in
            if let err = err {
              print("유저 등록 실패: \(err)")
            } else {
              print("유저 등록 성공")
            }
        }
    }
    
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func startSignInWithAppleFlow() {
        print("SignInViewController - startSignInWithAppleFlow()")
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
        }

        return String(nonce)
        }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    /// 애플로그인 dismiss 됐을때 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("SignInViewController - authorizationController(didCompleteWithAuthorization:)")

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                            rawNonce: nonce,
                                                            fullName: appleIDCredential.fullName)
            signInWithCredential(credential: credential, provider: .apple)
        }
    }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

}
