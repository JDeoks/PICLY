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
    let imageTuples: [(Int, UIImage)] = [(0, UIImage(named: "defaultImage")!)]
    
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
    /// getUserModelFromServer() -> AcountViewController
    let getUserModelDone = PublishSubject<Void>()
    /// fetchUserAuth() -> MainTabBarController
    let fetchUserAuthFailed = PublishSubject<Void>()
    /// uploadAlbum() -> SignInViewController
    let uploadAlbumDone = PublishSubject<Void>()

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
//        vc.view.addSubview(loadingView)
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
                        self.uploadAlbum {
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
    
    
    // MARK: - UserModel, UserDoc 처리
    /// LoginManager user 변수에 서버에 저장되어있는 UserModel 저장
    func getUserModelFromServer() {
        print("\(type(of: self)) - \(#function)")

        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        let userDocRef = userCollectionRef.document(userID)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = UserModel(document: document)
                self.setUserModelToLocal(user: user)
                print(user)
                self.setUserModelToLocal(user: user)
                self.getUserModelDone.onNext(())
            } else {
                print("User Doc 없음")
            }
        }
    }
    
    func getUserModelFromLocal() -> UserModel? {
        print("\(type(of: self)) - \(#function)")
        
        guard let data = UserDefaults.standard.data(forKey: "currentUserModel") else {
            print("UserDefaults에서 currentUser 가져오기 실패")
            return nil
        }

        do {
            // 디코딩 사용에 허용된 클래스 목록 정의
            let allowedClasses = [UserModel.self, NSString.self, NSDate.self, NSArray.self] as [AnyClass]
            let allowedClassesSet = NSSet(array: allowedClasses)

            // NSKeyedUnarchiver를 사용하여 data를 UserModel 객체로 디코딩
            if let user = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClassesSet as! Set<AnyHashable>, from: data) as? UserModel {
                print("UserModel 디코딩 성공")
                return user
            } else {
                print("UserModel 디코딩 실패: 디코딩된 객체가 UserModel 타입이 아님")
            }
        } catch {
            print("UserModel 디코딩 실패: \(error)")
        }
        return nil
    }
            
    /// UserModel을 로컬에 저장
    func setUserModelToLocal(user: UserModel) {
        print("\(type(of: self)) - \(#function)")

        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "currentUserModel")
            print("UserModel 인코딩 성공")
        } catch {
            print("UserModel 인코딩 실패: \(error)")
        }
    }
    
    // MARK: - 첫 앨범 업로드
    func uploadAlbum(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        uploadAlbumDocToFireStore() { albumDocID in
            self.uploadImagesToStorage(albumDocID: albumDocID) {
                self.updateImageURLsToAlbumDoc(albumDocID: albumDocID) {
                    self.signInWithCredentialDone.onNext(())
                }
            }
        }
    }
    
    /// AlbumModel을 FireStore에 추가
    private func uploadAlbumDocToFireStore( completion: @escaping (String) -> Void) {
        print("\(type(of: self)) - \(#function)")
        let imageSizes = getImageSizeDicts(images: imageSizeTuples)
        dump(imageSizes)
        let documentData = AlbumModel.createDictToUpload(
            expireTime: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            imageCount: imageTuples.count,
            tags: ["PiCo"],
            imageSizes: imageSizes
        )
        var ref: DocumentReference? = nil
        ref = albumCollection.addDocument(data: documentData) { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
            } else {
                print("\(#function) 성공: \(ref!.documentID)")
                let rootURL: URL = ConfigManager.shared.getRootURL()
                completion(ref!.documentID)
            }
        }
    }
    
    /// 이미지를 Storage에 업로드
    private func uploadImagesToStorage(albumDocID: String, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        // 스토리지 ref = albumDocID/imageIndex
        let albumImagesRef = Storage.storage().reference().child(albumDocID)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadGroup = DispatchGroup()
        // 썸네일 업로드
        if imageTuples.isEmpty == false {
            let uploadRef = albumImagesRef.child("thumbnail.jpeg")
            if let thumbnailImage = imageTuples[0].1.jpegData(compressionQuality: 0.1) {
                uploadGroup.enter()
                uploadRef.putData(thumbnailImage, metadata: metadata) { metadata, error in
                    uploadRef.downloadURL { url, error in
                        guard let url = url else {
                            return
                        }
                        self.thumbnailURL = url
                        uploadGroup.leave()
                    }
                }
            }
        }
        // 앨범 전체 이미지 업로드
        for imageIdx in 0..<imageTuples.count {
            let uploadRef = albumImagesRef.child("\(imageIdx).jpeg")
            if let imageData = imageTuples[imageIdx].1.jpegData(compressionQuality: 0.5) {
                uploadGroup.enter()
                uploadRef.putData(imageData, metadata: metadata) { metadata, error in
                    uploadRef.downloadURL { url, error in
                        guard let url = url else {
                            return
                        }
                        self.imageURLs.append((imageIdx,url))
                        uploadGroup.leave()
                    }
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            self.imageURLs.sort { $0.0 < $1.0 }
            completion()
        }
    }
    
    private func updateImageURLsToAlbumDoc(albumDocID: String, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        let albumDocRef = albumCollection.document(albumDocID)
        // imageURLs 배열을 String 배열로 변환
        let urlsStringArray = imageURLs.map { $0.1.absoluteString }
        let thumbnailStr: String = thumbnailURL?.absoluteString ?? "nil"
        let dict: [String : Any] = [AlbumField.imageURLs.rawValue: urlsStringArray, AlbumField.thumbnailURL.rawValue: thumbnailStr]
        albumDocRef.updateData(dict) { error in
            if let error = error {
                print("Doc 업데이트 실패: \(error)")
            } else {
                print("Doc 업데이트 성공")
                completion()
            }
        }
    }
    
    private func getImageSizeDicts(images: [(Int, CGFloat, CGFloat)]) -> [[String : Int]] {
        print("\(type(of: self)) - \(#function)")

        return images.map { (_, height, width) in
            [
                AlbumField.height.rawValue: Int(height),
                AlbumField.width.rawValue: Int(width)
            ]
        }
    }
    
    // MARK: - Auth 정보 처리
    /// 서버에서 유저 Auth 정보 받아 갱신
    func fetchUserAuth() {
        print("\(type(of: self)) - \(#function)")

        if let user = Auth.auth().currentUser {
            // 서버에서 사용자 상태 갱신
            user.reload { error in
                guard let error = error else {
                    print("user.reload 성공")
                    return
                }
                self.handleFirebaseAuthError(error: error as NSError)
            }
        } else {
            print("currentUser 없음")
            self.fetchUserAuthFailed.onNext(())
        }
    }
    
    // MARK: - 로그아웃, 회원 탈퇴
    func signOut() {
        print("\(type(of: self)) - \(#function)")
        
        do {
            try Auth.auth().signOut()
            // 성공적으로 로그아웃 처리됨
            print("성공적으로 로그아웃됨")
            UserDefaults.standard.removeObject(forKey: "currentUserModel")
        } catch let signOutError as NSError {
            // 로그아웃 과정에서 오류 발생
            print("로그아웃 실패: \(signOutError.localizedDescription)")
        }
    }
    
    // TODO: 계정 삭제
    func deleteUser() {
        print("\(type(of: self)) - \(#function)")
        let user = Auth.auth().currentUser
        var credential: AuthCredential

        // Prompt the user to re-provide their sign-in credentials

//        user?.reauthenticate(with: credential) { error in
//          if let error = error {
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }

        guard let user = Auth.auth().currentUser else {
            print("로그인된 사용자가 없습니다.")
            return
        }
        deleteUserDoc(userID: user.uid)

        // Firestore에서 사용자 문서 삭제
        userCollectionRef.document(user.uid).delete() { error in
            if let error = error {
                // Firestore 문서 삭제 실패
                print("Firestore 사용자 문서 삭제 실패: \(error)")
                return
            } else {
                // Firestore 문서 삭제 성공, 이제 Firebase 계정 삭제
                user.delete { error in
                    if let error = error {
                        // Firebase 계정 삭제 실패
                        print("\(type(of: self)) - \(#function) 실패: \(error)")
                    } else {
                        // Firebase 계정 삭제 성공
                        print("\(type(of: self)) - \(#function) 성공")
                    }
                }
            }
        }
    }
    
    private func deleteUserDoc(userID: String) {
        // TODO: 유저Doc 삭제
    }
    
    // MARK: - 에러 핸들링
    private func handleFirebaseAuthError(error: NSError) {
        switch error.code {
        case AuthErrorCode.networkError.rawValue:
            // 네트워크 오류 처리
            print("네트워크 오류 발생. 인터넷 연결 확인 필요.")
            //TODO: 네트워크 불량 Alert
        case AuthErrorCode.userNotFound.rawValue:
            // 사용자를 찾을 수 없음
            print("사용자 계정을 찾을 수 없습니다.")
            self.fetchUserAuthFailed.onNext(())
        case AuthErrorCode.userTokenExpired.rawValue:
            // 사용자 토큰 만료
            print("사용자 토큰이 만료되었습니다. 다시 로그인해주세요.")
        case AuthErrorCode.tooManyRequests.rawValue:
            // 너무 많은 요청
            print("요청이 너무 많습니다. 잠시 후에 다시 시도해주세요.")
        case AuthErrorCode.invalidEmail.rawValue, AuthErrorCode.wrongPassword.rawValue:
            // 잘못된 이메일 또는 비밀번호
            print("이메일 주소가 잘못되었거나 비밀번호가 틀렸습니다.")
        case AuthErrorCode.userDisabled.rawValue:
            // 사용자 계정 비활성화
            print("사용자 계정이 비활성화되었습니다.")
            self.fetchUserAuthFailed.onNext(())
        case AuthErrorCode.operationNotAllowed.rawValue:
            // 허용되지 않은 작업
            print("이 작업은 현재 허용되지 않습니다.")
            self.fetchUserAuthFailed.onNext(())
        default:
            // 기타 오류
            print("알 수 없는 오류 발생: \(error.localizedDescription)")
            self.fetchUserAuthFailed.onNext(())
        }
    }

}
