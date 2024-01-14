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
        
        if let user = UserManager.shared.getUserModelFromLocal() {
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
                HapticManager.shared.triggerImpact()
                self.showUploadFinishedAlert()
            }
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe { _ in
                // TODO: - 계정 삭제(올린 앨범들은 삭제되지 않습니다.)
                HapticManager.shared.triggerImpact()
                UserManager.shared.deleteUser()
                SceneManager.shared.setSignInVCAsRoot(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        print("\(type(of: self)) - \(#function)")
    }

}

extension AcountViewController {

    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "로그아웃", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            UserManager.shared.signOut()
            SceneManager.shared.setSignInVCAsRoot(animated: true)
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        sheet.addAction(loginAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
}
