//
//  SettingViewController.swift
//  PICLY
//
//  Created by 서정덕 on 11/24/23.
//

import UIKit
import FirebaseFirestore

class SettingViewController: UIViewController {
    
    var menus = [
        ["계정 관리", "튜토리얼 보기", "신고하기"],
        ["이용약관", "개인정보 처리방침","오픈소스 라이센스", "개발자 정보", "버전"]]
    var menuImages = ["person.fill", "book.fill", "exclamationmark.triangle.fill"]
    let urls = [
        "https://jdeoks.notion.site/5cc8688a9432444eaad7a8fdc4e4e38a",
        "https://jdeoks.notion.site/bace573d0a294bdeae4a92464448bcac",
        "https://jdeoks.notion.site/ca304e392e1246abbd51fe0bc37e76bb",
        "https://jdeoks.notion.site/a747b302e36f4c369496e7372768d685",
    ]
    
    let reportsCollection = Firestore.firestore().collection("Reports")
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    
    @IBOutlet var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
    }
    
    private func initUI() {
        // 네비게이션 바
        self.navigationController?.navigationBar.isHidden = true

        // menuTableView
        menuTableView.dataSource = self
        menuTableView.delegate = self
        let settingsTableViewCell = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        menuTableView.register(settingsTableViewCell, forCellReuseIdentifier: "SettingsTableViewCell")
    }
    
    private func initData() {
        if UserManager.shared.getCurrentUserModel()?.email == "duginee@naver.com" {
            menus[0].append("유저 차단하기")
            menuImages.append("person.crop.circle.fill.badge.xmark")
            menuTableView.reloadData()
        }
    }

}

// MARK: - UITableView
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        menus.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        cell.menuLabel.text = menus[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            cell.menuImageView.image = UIImage(systemName: menuImages[indexPath.row])
            
        case 1:
            cell.imageContainerView.isHidden = true
            if indexPath.row == 4 {
                cell.versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            }
            
        default:
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            return 72
        case 1:
            return 48
        default:
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        // 메인
        case 0:
            switch indexPath.row {
            // 계정 관리
            case 0:
                SceneManager.shared.pushAccountVC(vc: self)
                
            // 튜토리얼 보기
            case 1:
                SceneManager.shared.presentOnboardingVC(vc: self, animated: true)
            
            // 신고하기
            case 2:
                showReportAlert()
            
            // 유저 차단하기
            case 3:
                showBlockUserAlert()
                
            default:
                return
            }
            
        // 노션 웹뷰
        case 1:
            if urls.indices.contains(indexPath.row) == false {
                return
            }
            guard let url = URL(string: urls[indexPath.row]) else {
                print("url 없음")
                return
            }
            SceneManager.shared.presentWebVC(vc: self, url: url)
        default:
            return
        }
    }
    
}

extension SettingViewController {
    
    // MARK: - 신고하기 로직
    /// 신고제출하기 Alert 표시
    func showReportAlert() {
        print("\(type(of: self)) - \(#function)")
        
        let reportAlert = UIAlertController(title: "신고하기", message: "신고할 앨범의 URL을 입력해주세요.", preferredStyle: .alert)
        
        reportAlert.addTextField { textField in
            textField.placeholder = "URL을 입력해주세요."
            // 텍스트 필드의 텍스트가 변경될 때마다 호출될 클로저를 설정
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                reportAlert.actions.first?.isEnabled = !textField.text!.isEmpty
            }
        }
        
        // 제출 버튼, 처음에는 비활성화 상태로 시작.
        let submitAction = UIAlertAction(title: "제출", style: .default) { action in
            // 제출 로직
            self.view.addSubview(self.loadingView)
            guard let urlStr = reportAlert.textFields?.first?.text else {
                return
            }
            self.submitReport(urlStr: urlStr)
        }
        submitAction.isEnabled = false // 초기에는 제출 버튼을 비활성화.
        reportAlert.addAction(submitAction)
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        reportAlert.addAction(cancelAction)
        
        present(reportAlert, animated: true)
    }
    
    /// 신고 제출 완료 Alert  표시
    func showReportSubmited() {
        print("\(type(of: self)) - \(#function)")
        
        let reportSubmitedAlert = UIAlertController(title: "신고 완료", message: "신고해주셔서 감사합니다.\n제출하신 신고는 24시간 이내에 검토됩니다.", preferredStyle: .alert)
        // 확인
        let okAction = UIAlertAction(title: "확인", style: .default)
        reportSubmitedAlert.addAction(okAction)
        
        self.loadingView.removeFromSuperview()
        present(reportSubmitedAlert, animated: true)
    }
    
    /// 신고 제출 실패 Alert  표시
    func showReportSubmitFailed() {
        print("\(type(of: self)) - \(#function)")
        
        let reportSubmitFailedAlert = UIAlertController(title: "신고 제출 실패", message: "신고를 제출하는 과정에서 문제가 발생했습니다.\n네트워크 연결을 확인하신 후, 다시 시도해주세요.", preferredStyle: .alert)
        // 확인
        let okAction = UIAlertAction(title: "확인", style: .default)
        reportSubmitFailedAlert.addAction(okAction)
        
        self.loadingView.removeFromSuperview()
        present(reportSubmitFailedAlert, animated: true)
    }
     
    func submitReport(urlStr: String) {
        print("\(type(of: self)) - \(#function)")
        
        var ref: DocumentReference? = nil
        let reportDict: Dictionary = [
            ReportField.reportedAlbumURL.rawValue: urlStr,
            ReportField.reportingUser.rawValue: UserManager.shared.getCurrentUserModel()?.userID ?? "nil",
            ReportField.creationTime.rawValue: Timestamp()
        ] as [String : Any]
        
        ref = reportsCollection.addDocument(data: reportDict) { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
                self.showReportSubmitFailed()
            } else {
                print("\(#function) 성공: \(ref!.documentID)")
                self.showReportSubmited()
            }
        }
    }
    
    // MARK: - 유저 차단 로직
    
    func showBlockUserAlert() {
        print("\(type(of: self)) - \(#function)")
        
        let reportAlert = UIAlertController(title: "유저 차단하기", message: "차단할 유저의 URL을 입력해주세요.", preferredStyle: .alert)
        
        reportAlert.addTextField { textField in
            textField.placeholder = "URL을 입력해주세요."
            // 텍스트 필드의 텍스트가 변경될 때마다 호출될 클로저를 설정
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                reportAlert.actions.first?.isEnabled = !textField.text!.isEmpty
            }
        }
        
        // 제출 버튼, 처음에는 비활성화 상태로 시작.
        let submitAction = UIAlertAction(title: "제출", style: .default) { action in
            // 제출 로직
            self.view.addSubview(self.loadingView)
            guard let urlStr = reportAlert.textFields?.first?.text else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.showBlockUserCompletedAlert()
            }
        }
        submitAction.isEnabled = false // 초기에는 제출 버튼을 비활성화.
        reportAlert.addAction(submitAction)
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        reportAlert.addAction(cancelAction)
        
        present(reportAlert, animated: true)
    }
    
    func showBlockUserCompletedAlert() {
        let reportSubmitedAlert = UIAlertController(title: "차단 완료", message: nil, preferredStyle: .alert)
        // 확인
        let okAction = UIAlertAction(title: "확인", style: .default)
        reportSubmitedAlert.addAction(okAction)
        
        self.loadingView.removeFromSuperview()
        present(reportSubmitedAlert, animated: true)
    }
}

