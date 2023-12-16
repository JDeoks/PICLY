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
    var user: UserModel? = nil
    
    let fetchAccountInfoDone = PublishSubject<Void>()
    
    private init() {}
    
    func fetchAccountInfo() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        let userDocRef = userCollectionRef.document(userID)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.user = UserModel(document: document)
                self.fetchAccountInfoDone.onNext(())
            } else {
                print("User Doc 없음")
            }
        }
    }
    
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

}
