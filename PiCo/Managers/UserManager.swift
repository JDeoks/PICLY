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
    // TODO: 코드 개선 필요
    /// 유저 Doc 생성
    func uploadUserDocToDB(user: User, provider: AuthProvider, completion: @escaping () -> Void) {
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
    
    func getCurrentUserModel() -> UserModel? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil 
        }
        let user = UserModel(user: currentUser)
        return user
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
