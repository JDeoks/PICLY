//
//  UserManager.swift
//  PiCo
//
//  Created by JDeoks on 1/10/24.
//

import Foundation
import RxSwift
import Firebase
import FirebaseFirestore
import FirebaseAuth

/// Auth 정보, User Doc  관리
class UserManager {
    
    static let shared = UserManager()
    
    private init() { }
    
    let albumCollection = Firestore.firestore().collection("Albums")
    let userCollectionRef = Firestore.firestore().collection("Users")
    
    /// getUserModelFromServer() -> AcountViewController
    let getUserModelDone = PublishSubject<Void>()
    /// fetchUserAuth() -> MainTabBarController
    let fetchUserAuthFailed = PublishSubject<Void>()
    
    /// 첫 로그인 정보 설정
    func hasCompletedInitialLaunch() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedInitialLaunch")
    }

    func setHasCompletedInitialLaunch(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: "hasCompletedInitialLaunch")
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
    
    /// 로컬에 저장된 UserModel 반환
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
    /// 로그아웃
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
    
    /// 회원 탈퇴
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
