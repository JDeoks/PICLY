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
    
    // Unhashed nonce.
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
                    
                    })
                    .disposed(by: disposeBag)
        
        signInWithAppleButtonView.rx.tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.startSignInWithAppleFlow()
                    })
                    .disposed(by: disposeBag)
    }
    
    func googleLogin() {
        /// Firebase 프로젝트에 부여되는 고유 식별자 OAuth과정에서 애플리케이션 식별할 때 사용
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
            print("구글 signIn 실패")
            return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("user 정보 가져오기 실패")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                if let result = result {
                    print("registerUser 성공")
                    print("인증 프로바이더 아이디",result.user.providerID)
                    self.addUserInfoToDB(id: result.user.uid, userName: userName)
                }
            // At this point, our user is signed in
            }
        }
    }
    
    /// 유저 Doc 생성
    func addUserToDB(id: String, userName: String, imageURL: String) {
        print("addUserToDB - id: \(id) userName: \(userName) imageURL: \(imageURL)")
        let db = Firestore.firestore()
        db.collection("users").document(id).setData([
          "userName": userName,
          "profileImageURL": imageURL
        ]){ err in
            if let err = err {
              print("Error writing document: \(err)")
            } else {
              print("Document successfully written!")
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
    
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
      // Sign in with Firebase.
//      Auth.auth().signIn(with: credential) { (authResult, error) in
//        if error {
//          // Error. If error.code == .MissingOrInvalidNonce, make sure
//          // you're sending the SHA256-hashed nonce as a hex string with
//          // your request to Apple.
//          print(error.localizedDescription)
//          return
//        }
//        // User is signed in to Firebase with Apple.
//        // ...
//      }
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
