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
        
    let loginManager = LoginManager()
    
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    
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
                self.showSignOutAlert()
            }
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.showDeleteAccountAlert()
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        print("\(type(of: self)) - \(#function)")
    }

}

extension AcountViewController {

    func showSignOutAlert() {
        print("\(type(of: self)) - \(#function)")

        let sheet = UIAlertController(title: "로그아웃", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        let signOutAction = UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.performSignOut()
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        sheet.addAction(signOutAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
    func showDeleteAccountAlert() {
        print("\(type(of: self)) - \(#function)")

        let sheet = UIAlertController(title: "계정 탈퇴", message: "탈퇴 시 앨범은 자동으로 삭제되지 않으며,\n계정은 복구되지 않습니다.\n정말로 탈퇴하시겠습니까?", preferredStyle: .alert)
        let deleteUserAction = UIAlertAction(title: "탈퇴", style: .destructive, handler: { _ in
            self.view.addSubview(self.loadingView)
            self.loginManager.deleteUser { result in
                print("self.loginManager.deleteUser:", result)
                
                self.loadingView.removeFromSuperview()
                if result {
                    self.showAccountDeletedAlert()
                } else {
                    self.showLockAlert(message: "탈퇴 실패.\n앱을 다시 실행해주세요.")
                }
            }
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        sheet.addAction(deleteUserAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
    func showReauthenticationRequiredAlert() {
        print("\(type(of: self)) - \(#function)")

        let sheet = UIAlertController(title: "재인증 필요", message: "계정 탈퇴를 위해서는 재인증이 필요합니다. \n로그아웃하시겠습니까?", preferredStyle: .alert)
        let signOutAction = UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.performSignOut()
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        sheet.addAction(signOutAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
    func performSignOut() {
        print("\(type(of: self)) - \(#function)")
        
        self.view.addSubview(self.loadingView)
        loginManager.signOut { result in
            if result {
                SceneManager.shared.setSignInVCAsRoot(animated: true)
            } else {
                self.showLockAlert(message: "로그아웃 실패.\n앱을 다시 실행해주세요.")
            }
            self.loadingView.removeFromSuperview()
        }
    }
    
    func showAccountDeletedAlert() {
        print("\(type(of: self)) - \(#function)")

        let sheet = UIAlertController(title: "탈퇴 완료", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            SceneManager.shared.setSignInVCAsRoot(animated: true)
        }
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
}
