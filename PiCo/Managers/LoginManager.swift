//
//  LoginManager.swift
//  PiCo
//
//  Created by JDeoks on 12/17/23.
//

import Foundation
import RxSwift
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseCore
import FirebaseStorage

class LoginManager: NSObject {
    
    static let shared = LoginManager()
    
    private override init() {
        super.init()
    }
    
    /// Unhashed nonce. 애플로그인 암호화에 사용
    fileprivate var currentNonce: String?
    /// LoginManager에 로그인 요청한 VC
    var requestingLoginVC: UIViewController! = nil
    let albumCollection = Firestore.firestore().collection("Albums")
    let userCollectionRef = Firestore.firestore().collection("Users")
    /// 선택한 사진 배열  param1: index, param2: image
    var imageTuples: [(Int, UIImage)] = [(0, UIImage(named: "defaultImage")!)]
    var tags = ["PiCo", "새로운", "공유의", "시작"]
    /// 기본 앨범 썸네일 URL
    var thumbnailURL: URL?
    /// 앨범에 추가할 이미지 접근 URLs
    var imageURLs: [(Int, URL)] = []
    /// param1: index, param2: height, param3: width
    var imageSizeTuples: [(Int, CGFloat, CGFloat)] = [(0, UIImage(named: "defaultImage")!.size.height, UIImage(named: "defaultImage")!.size.width)]
    
    /// startSignInWithGoogleFlow(), startSignInWithAppleFlow() -> SignInViewController, SettingViewController
    let signInFailed = PublishSubject<Void>()
    /// signInWithCredential() -> SignInViewController
    let signInWithCredentialDone = PublishSubject<Void>()

// MARK: - 구글 로그인
    func startSignInWithGoogleFlow(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        
        // 로그인 요청한 vc 설정
        requestingLoginVC = vc

        /// Firebase 프로젝트에 부여되는 고유 식별자. OAuth과정에서 애플리케이션 식별할 때 사용
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("clientID 초기화 실패")
            return
        }
        // Google Sign In 초기설정
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 구글 로그인 뷰 띄우기, dismiss 됐을 때 만든 credential로 로그인
        GIDSignIn.sharedInstance.signIn(withPresenting: requestingLoginVC) { [unowned self] result, error in
            if let error = error {
                // TODO: 로그인 실패 Alert
                signInFailed.onNext(())
                print("구글 signIn 실패: \(error)")
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
}
    
// MARK: - 애플 로그인
extension LoginManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func startSignInWithAppleFlow(vc: UIViewController) {
        print("\(type(of: self)) - \(#function)")
        // 로그인 요청한 vc 설정
        requestingLoginVC = vc
        
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
        print("\(type(of: self)) - \(#function)")

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
        signInFailed.onNext(())
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let window: UIWindow = requestingLoginVC.view.window!
        return window
    }
    
}

extension LoginManager {
    
    // MARK: - 로그인 공통 로직
    func signInWithCredential(credential: AuthCredential, provider: AuthProvider) {
        print("\(type(of: self)) - \(#function)")

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
            // 첫 로그인 시 User Collection에 Doc 추가
            self.isFirstLogin(user: user) { isFirstLogin in
                if isFirstLogin {
                    print("첫 번째 로그인")
                    self.addUserToDB(user: user, provider: provider) {
                        let expireDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                        self.imageTuples.sort { $0.0 < $1.0 }
                        let images: [UIImage] = self.imageTuples.map{ return $1 }
                        let albumDict = AlbumModel.createDictToUpload(expireTime: expireDate, images: images, tags: self.tags)
                        DataManager.shared.uploadAlbum(albumDict: albumDict, images: images) {
                            self.signInWithCredentialDone.onNext(())
                        }
                    }
                } else {
                    print("기존 사용자")
                    self.signInWithCredentialDone.onNext(())
                }
            }
        }
    }
    
    /// User Collection에 userID의 Doc이 있는지 검사
    private func isFirstLogin(user: User, completion: @escaping (Bool) -> Void) {
        print("\(type(of: self)) - \(#function)")

        let userDocRef = userCollectionRef.document(user.uid)

        userDocRef.getDocument { (document, error) in
            if let error = error {
                print(error)
                return
            }
            // 문서가 존재하지 않을 때 첫 로그인 -> true 반환
            if let document = document, document.exists {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    /// 유저 Doc 생성
    private func addUserToDB(user: User, provider: AuthProvider, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        userCollectionRef.document(user.uid).setData(UserModel.createDictToUpload(provider: provider, user: user)){ err in
            if let err = err {
              print("\(#function) 유저 등록 실패: \(err)")
            } else {
              print("\(#function) 유저 등록 성공")
                completion()
            }
        }
    }

}
