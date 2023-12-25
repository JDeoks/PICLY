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
        
    let disposeBag = DisposeBag()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var authProviderLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var deleteAccountButton: UIButton!
    @IBOutlet var registrationDate: UILabel!
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        
        super.viewDidLoad()
        initUI()
        initData()
        action()
        bind()
    }
    
    func initUI() {
        print("\(type(of: self)) - \(#function)")
    }
    
    func initData() {
        print("\(type(of: self)) - \(#function)")
        
        if let user = LoginManager.shared.getUserModelFromLocal() {
            authProviderLabel.text = "\(user.authProvider.rawValue)로 로그인"
            emailLabel.text = user.email
            registrationDate.text = user.getCreationTimeString()
        }
    }
    
    func action() {
        print("\(type(of: self)) - \(#function)")
        
        backButton.rx.tap
            .subscribe { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        signOutButton.rx.tap
            .subscribe { _ in
                LoginManager.shared.signOut()
                SceneManager.shared.setSignInVCAsRoot(animated: true)
            }
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe { _ in
                // TODO: - 계정 삭제(올린 앨범들은 삭제되지 않습니다.)
                LoginManager.shared.deleteUser()
                SceneManager.shared.setSignInVCAsRoot(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        print("\(type(of: self)) - \(#function)")
    }

}
