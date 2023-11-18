//
//  DetailViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var editButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var viewsLabel: UILabel!
    @IBOutlet var expireDateLabel: UILabel!
    @IBOutlet var copyLinkButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
    }
    
    func initUI() {
        imageView.layer.cornerRadius = 4
        shareButton.layer.cornerRadius = 4
    }
    
    func action() {
        editButton.rx.tap
            .subscribe { _ in
                self.showEditActionSheet()
            }
            .disposed(by: disposeBag)
    }

}

extension DetailViewController {
    // MARK: - ActionSheet, Alert

    func showEditActionSheet() {
        let actionSheet = UIAlertController(title: "메뉴", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
            print("정보 수정")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.showDeleteConfirmationAlert()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showDeleteConfirmationAlert() {
        let deleteAlert = UIAlertController(title: "삭제 확인", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.deleteAction()
        })
        deleteAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteAction() {
       print("글 삭제")
    }
}
