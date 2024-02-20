//
//  SettingViewController.swift
//  PICLY
//
//  Created by 서정덕 on 11/24/23.
//

import UIKit

class SettingViewController: UIViewController {
    
    let menus = [
        ["계정 관리", "튜토리얼 보기"],
        ["이용약관", "개인정보 처리방침","오픈소스 라이센스", "개발자 정보", "버전"]]
    let menuImages = ["person.fill", "book.fill", "star.fill"]
    let urls = [
        "https://jdeoks.notion.site/5cc8688a9432444eaad7a8fdc4e4e38a",
        "https://jdeoks.notion.site/bace573d0a294bdeae4a92464448bcac",
        "https://jdeoks.notion.site/ca304e392e1246abbd51fe0bc37e76bb",
        "https://jdeoks.notion.site/a747b302e36f4c369496e7372768d685",
    ]
    
    @IBOutlet var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        // 네비게이션 바
        self.navigationController?.navigationBar.isHidden = true

        // menuTableView
        menuTableView.dataSource = self
        menuTableView.delegate = self
        let settingsTableViewCell = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        menuTableView.register(settingsTableViewCell, forCellReuseIdentifier: "SettingsTableViewCell")
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
            case 1:
                SceneManager.shared.presentOnboardingVC(vc: self, animated: true)
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
