//
//  LoginManager.swift
//  PICLY
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
        
    override init() {
        super.init()
    }
    
    /// Unhashed nonce. 애플로그인 암호화에 사용
    fileprivate var currentNonce: String?
    /// LoginManager에 로그인 요청한 VC
    var requestingLoginVC: UIViewController! = nil
    let albumCollection = Firestore.firestore().collection("Albums")
    let userCollectionRef = Firestore.firestore().collection("Users")
    /// 선택한 사진 배열  param1: index, param2: image
    var images: [UIImage] = [UIImage(named: "defaultImage")!]
    var tags = ["PICLY", "새로운", "공유의", "시작"]
    /// 기본 앨범 썸네일 URL
    var thumbnailURL: URL?
    /// 앨범에 추가할 이미지 접근 URLs
    var imageURLs: [(Int, URL)] = []
    /// createUserWithEmail() -> EmailSignInVC
    let createUserWithEmailFailed = PublishSubject<String>()
    /// startSignInWithGoogleFlow(), startSignInWithAppleFlow() -> SignInViewController, SettingViewController
    let signInFailed = PublishSubject<String>()
    /// signInWithCredential() -> SignInViewController
    let signInProcessDone = PublishSubject<Void>()

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
                signInFailed.onNext("로그인 실패\n\(error.localizedDescription)")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                // TODO: 로그인 실패 Alert
                signInFailed.onNext("로그인 실패\nuser 없음")
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
        signInFailed.onNext("Apple 로그인 실패")
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let window: UIWindow = requestingLoginVC.view.window!
        return window
    }
    
}

extension LoginManager {
    
    // MARK: - OAuth 공통 로직
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
                    self.setUpFirstLogin(user: user, provider: provider) {
                        self.signInProcessDone.onNext(())
                    }
                } else {
                    print("기존 사용자")
                    self.signInProcessDone.onNext(())
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
    
    // MARK: - 이메일 로그인, 회원가입
    /// 사진,  이메일, 이름, 비밀번호로 회원가입
    func createUserWithEmail(email: String, password: String) {
        print("\(type(of: self)) - \(#function)")

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                let errorMessage = self.convertErrorToMessage(error: error)
                self.createUserWithEmailFailed.onNext(errorMessage)
                return
            }
            guard let authResult = authResult else {
                self.createUserWithEmailFailed.onNext("회원가입 실패\nauthResult 없음")
                return
            }
            let user = authResult.user
            self.setUpFirstLogin(user: user, provider: .email) {
                self.performLogin(email: email, password: password)
            }
        }
    }
    
    func performLogin(email: String, password: String) {
        print("\(type(of: self)) - \(#function)")

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("performLogin 오류\(error.localizedDescription)")
                self.signInFailed.onNext("이메일 혹은 비밀번호가 일치하지 않습니다.")
                return
            }
            print("\(#function) 성공")
            self.signInProcessDone.onNext(())
        }
    }
    
    // MARK: - 로그인 공통 로직
    /// 첫 로그인 시 실행하는 로직. UserDoc 생성, 기본 AlbumDoc 생성
    func setUpFirstLogin(user: User, provider: AuthProvider, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        UserManager.shared.uploadUserDocToDB(user: user, provider: provider) {
            let expireDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
            let albumDict = AlbumModel.createDictToUpload(expireTime: expireDate, images: self.images, tags: self.tags)
            DataManager.shared.uploadAlbum(albumDict: albumDict, images: self.images) { albumURL in
                completion()
            }
        }
    }
    
    // MARK: - 로그아웃, 회원 탈퇴
    /// 회원 탈퇴
    func deleteUser(completion: @escaping (_ result: Bool) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        guard let user = Auth.auth().currentUser else {
            print("\(#function) currentUser 없음")
            completion(false)
            return
        }
        
        print("\(#function) currentUser 있음")
        self.deleteUserDoc { result in
            print("\(#function) deleteUserDoc result: \(result)")
            if !result {
                completion(false)
                return
            }
            user.delete { error in
                if error != nil {  // 에러가 발생한 경우
                    print("\(#function) user.delete:", error!.localizedDescription)
                    completion(false)  // 재인증 함수 호출
                } else {  // 에러가 발생하지 않은 경우
                    print("\(#function) user.delete error == nil")
                }
                self.signOut { result in
                    print("\(#function) signOut result: \(result)")
                    if result {
                        completion(result)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    /// UsersCollection에서 현재유저 삭제
    private func deleteUserDoc(completion: @escaping (_ result: Bool) -> Void) {
        print("\(type(of: self)) - \(#function)")

        guard let user = Auth.auth().currentUser else {
            print("\(#function) currentUser 없음")
            completion(false)
            return
        }
        // Firestore에서 사용자 문서 삭제
        userCollectionRef.document(user.uid).delete() { error in
            if let error = error {
                // Firestore 문서 삭제 실패
                print("Firestore 사용자 문서 삭제 실패: \(error.localizedDescription)")
                completion(false)
                return
            }
            print("Firestore 사용자 문서 삭제 성공")
            completion(true)
        }
    }
    
    /// 로그아웃
    func signOut(completion: @escaping (_ result: Bool) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        do {
            try Auth.auth().signOut()
            // 성공적으로 로그아웃 처리됨
            print("성공적으로 로그아웃됨")
            UserDefaults.standard.removeObject(forKey: "currentUserModel")
            completion(true)
        } catch let signOutError as NSError {
            // 로그아웃 과정에서 오류 발생
            print("로그아웃 실패: \(signOutError.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - 에러 메시지 처리
    func convertErrorToMessage(error: Error) -> String{
        print("\(type(of: self)) - \(#function)")

        switch error.localizedDescription {
        case "The password must be 6 characters long or more.":
            return "비밀번호는 6자 이상이어야 합니다."
        case "The email address is already in use by another account.":
            return "이미 계정이 존재합니다."
        case "An email address must be provided.":
            return "이메일을 입력해주세요"
        case "The email address is badly formatted.":
            return "이메일을 형식에 맞게 기입해주세요."
        case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
            return "네트워크 오류. \n연결을 확인하고 다시 시도해 주세요."
        default:
            return error.localizedDescription
        }
    }

}

