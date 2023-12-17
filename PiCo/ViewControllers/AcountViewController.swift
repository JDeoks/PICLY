//
//  AcountViewController.swift
//  PiCo
//
//  Created by JDeoks on 12/17/23.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AcountViewController: UIViewController {
    
    let userCollectionRef = Firestore.firestore().collection("User")
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var authProviderLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
        bind()
        LoginManager.shared.getCurrentUser()
//        LoginManager.shared.fetchAccountInfo()
    }
    
    func initUI() {
        
    }
    
    func action() {
        signOutButton.rx.tap
            .subscribe { _ in
                
            }
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe { _ in
                
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        LoginManager.shared.fetchAccountInfoDone
            .subscribe { _ in
                self.setDataWithUserModel(user: LoginManager.shared.user!)
            }
            .disposed(by: disposeBag)
    }
    
//    func setDataWithCurrentUser() {
//        print("AcountViewController - setDataWithCurrentUser()")
//        
//        guard let user = LoginManager.shared.getCurrentUser() else {
//            return
//        }
//        
//        setDataWithUserModel(user: user)
//    }
    
    func setDataWithUserModel(user: UserModel) {
        print("AcountViewController - setDataWithUserModel()")

        authProviderLabel.text = "\(user.authProvider.description)로 로그인"
        emailLabel.text = user.email
    }

}
