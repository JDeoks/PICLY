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
    @IBOutlet var registrationDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
        bind()
        // 로컬 데이터로 초기화 후 바로 서버에서 유저정보 fetch해서 최신화
        LoginManager.shared.getUserModelFromLocal()
    }
    
    func initUI() {
        
    }
    
    func action() {
        signOutButton.rx.tap
            .subscribe { _ in
                LoginManager.shared.signOut()
                self.setSignInVCAsRoot()
            }
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe { _ in
                
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        LoginManager.shared.getUserModelDone
            .subscribe { _ in
                self.setDataWithUserModel(user: LoginManager.shared.user!)
            }
            .disposed(by: disposeBag)
    }
    
    func setDataWithUserModel(user: UserModel) {
        print("\(type(of: self)) - \(#function)")

        authProviderLabel.text = "\(user.authProvider.description)로 로그인"
        emailLabel.text = user.email
        registrationDate.text = user.getCreationTimeString()
    }
    
    
    // TODO: - 최적화 필요 뷰 컨트롤러 계속 생성함
    func setSignInVCAsRoot() {
        let window = UIApplication.shared.getWindow()
        // 넘어갈 화면
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController

        // 현재 루트 뷰 컨트롤러의 스냅샷 가져오기
        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else { return }

        // 새 루트 뷰 컨트롤러 설정
        window.rootViewController = signInVC

        // 스냅샷을 새 루트 뷰 컨트롤러 위에 추가
        signInVC.view.addSubview(snapshot)

        // 애니메이션을 통해 스냅샷을 서서히 사라지게 함
        UIView.animate(withDuration: 0.5, animations: {
            snapshot.layer.opacity = 0
        }) { _ in
            snapshot.removeFromSuperview()
        }
    }

}
