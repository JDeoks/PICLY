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
        LoginManager.shared.fetchAccountInfo()
    }
    
    func initUI() {
        
    }
    
    func action() {
        signOutButton.rx.tap
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
    
    func setDataWithUserModel(user: UserModel) {
        authProviderLabel.text = "\(user.authProvider.description)로 로그인"
        emailLabel.text = user.email
    }

}
