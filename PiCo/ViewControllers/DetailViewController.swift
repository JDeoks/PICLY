//
//  DetailViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    var albumURL: URL?
    var imageURL: URL?
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var backButton: UIButton!
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
        imageView.image = loadImageFromDirectory(with: "image.jpeg")
    }
    
    func action() {
        backButton.rx.tap
            .subscribe { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        editButton.rx.tap
            .subscribe { _ in
                self.showEditActionSheet()
            }
            .disposed(by: disposeBag)
        
        copyLinkButton.rx.tap
            .subscribe { _ in
                guard let url = self.albumURL else {
                    self.showToast(message: "링크 복사 실패")
                    return
                }
                UIPasteboard.general.url = url
                self.showToast(message: "링크가 복사되었습니다")
            }
            .disposed(by: disposeBag)
    }
    
    func loadImageFromDirectory(with idnetifier: String) -> UIImage? {
        let fileManager = FileManager.default
        // 파일 경로로 접근
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(idnetifier, conformingTo: .jpeg)
        print(fileURL)
        // 이미지 파일이 존재한다면, 이미지로 변환 후 리턴
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        return UIImage(contentsOfFile: fileURL.path)
    }

}

// MARK: - ActionSheet, Alert
extension DetailViewController {

    func showEditActionSheet() {
        let actionSheet = UIAlertController(title: "메뉴", message: "", preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
//            print("정보 수정")
//            let editVC = self.storyboard?.instantiateViewController(identifier: "EditViewController") as! EditViewController
//            self.navigationController?.pushViewController(editVC, animated: true)
//        }))
        actionSheet.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.showDeleteConfirmationAlert()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showDeleteConfirmationAlert() {
        let deleteAlert = UIAlertController(title: "삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
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
