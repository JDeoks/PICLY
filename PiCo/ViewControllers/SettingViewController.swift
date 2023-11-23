//
//  SettingViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/24/23.
//

import UIKit

class SettingViewController: UIViewController {
    
    let menus = [["계정 관리", "튜토리얼 보기", "앱 평가하기"],
                 ["피코 더 알아보기", "개인정보 처리방침", "이용약관", "오픈소스 라이센스", "버전", "개발자 정보"]]
    let menuImages = ["person.fill", "book.fill", "star.fill"]

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
        menuTableView.contentInset.top = 16
    }

}

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
        switch indexPath.section{
        case 0:
            cell.menuImageView.image = UIImage(systemName: menuImages[indexPath.row])
        case 1:
            cell.imageContainerView.isHidden = true
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
    
    
    
}
