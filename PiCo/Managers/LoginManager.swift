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

class LoginManager {
    
    static let shared = LoginManager()
        
    let userCollectionRef = Firestore.firestore().collection("User")
    /// fetchAccount 결과가 저장돠는 변수
    var user: UserModel? = nil
    /// getCurrentUser(), fetchAccountInfo() -> AcountViewController
    let fetchAccountInfoDone = PublishSubject<Void>()
    
    private init() {}
    
    func setUserID(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: "userID")
    }
    
    func getUserID() -> String? {
        return UserDefaults.standard.string(forKey: "userID")
    }
    
    func setEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: "email")
    }
    
    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: "email")
    }
    
    func setCreationTimeString(_ creationTimeString: String) {
        UserDefaults.standard.set(creationTimeString, forKey: "creationTimeString")
    }
    
    func getCreationTimeString() -> String? {
        return UserDefaults.standard.string(forKey: "creationTimeString")
    }
    
    func setAuthProviderString(_ creationTimeString: String) {
        UserDefaults.standard.set(creationTimeString, forKey: "authProviderString")
    }
    
    func getAuthProviderString() -> String? {
        return UserDefaults.standard.string(forKey: "authProviderString")
    }
    
    func fetchAccountInfo() {
        print("LoginManager - fetchAccountInfo()")

        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        let userDocRef = userCollectionRef.document(userID)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = UserModel(document: document)
                self.user = user
                self.setCurrentUser(user: user)
                self.fetchAccountInfoDone.onNext(())
            } else {
                print("User Doc 없음")
            }
        }
    }
    
    func getCurrentUser() {
        print("LoginManager - getCurrentUser()")
        
        guard let data = UserDefaults.standard.data(forKey: "currentUser") else {
            print("UserDefaults에서 currentUser 가져오기 실패")
            return
        }

        do {
            // 디코딩 사용에 허용된 클래스 목록 정의
            let allowedClasses = [UserModel.self, NSString.self, NSDate.self, NSArray.self] as [AnyClass]
            let allowedClassesSet = NSSet(array: allowedClasses)

            // NSKeyedUnarchiver를 사용하여 data를 UserModel 객체로 디코딩
            if let user = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClassesSet as! Set<AnyHashable>, from: data) as? UserModel {
                print("UserModel 디코딩 성공")
                self.user = user
                self.fetchAccountInfoDone.onNext(())
            } else {
                print("UserModel 디코딩 실패: 디코딩된 객체가 UserModel 타입이 아님")
            }
        } catch {
            print("UserModel 디코딩 실패: \(error)")
        }
    }
            
    func setCurrentUser(user: UserModel) {
        print("LoginManager - setCurrentUser()")

        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "currentUser")
        } catch {
            print("UserModel 인코딩 실패: \(error)")
        }
    }

}
