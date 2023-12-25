//
//  DetailViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    var album: AlbumModel!
    var albumURL: URL?
    let disposeBag = DisposeBag()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var viewCountLabel: UILabel!
    @IBOutlet var remainTimeLabel: UILabel!
    @IBOutlet var copyLinkButton: UIButton!
    @IBOutlet var detailTagsCollectionView: UICollectionView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
    }
    
    func initUI() {
        // imageView
        imageView.layer.cornerRadius = 4
        
        // shareButton
        shareButton.layer.cornerRadius = 4
        
        // scrollView
        scrollView.alwaysBounceVertical = true
        
        // detailTagsCollectionView
        detailTagsCollectionView.delegate = self
        detailTagsCollectionView.dataSource = self
        let detailTagsCollectionViewCell = UINib(nibName: "DetailTagsCollectionViewCell", bundle: nil)
        detailTagsCollectionView.register(detailTagsCollectionViewCell, forCellWithReuseIdentifier: "DetailTagsCollectionViewCell")
        let detailTagsFlowLayout = UICollectionViewFlowLayout()
        detailTagsFlowLayout.scrollDirection = .horizontal
        detailTagsCollectionView.collectionViewLayout = detailTagsFlowLayout
    }
    
    func initData() {
        dateLabel.text = album.getCreationTimeStr()
        if album.tags.isEmpty {
            tagLabel.text = "#"
        } else {
            tagLabel.text = "# \(album.tags[0])"
        }
        if album.tags.count <= 1 {
            detailTagsCollectionView.isHidden = true
        }
        viewCountLabel.text = "\(album.viewCount)"
        remainTimeLabel.text = album.getTimeRemainingStr()
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

// MARK: - UICollectionView
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case detailTagsCollectionView:
            /// 첫 태그 제외한 나머지 태그 개수
            let tagCount = album.tags.count - 1
            return tagCount > 0 ? tagCount : 0
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case detailTagsCollectionView:
            let cell = detailTagsCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailTagsCollectionViewCell", for: indexPath) as! DetailTagsCollectionViewCell
            cell.tagLabel.text = "# \(album.tags[indexPath.row + 1])"
            return cell
            
        default:
            return DetailTagsCollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case detailTagsCollectionView:
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
         
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case detailTagsCollectionView:
            let label = UILabel()
            label.text = "# \(album.tags[indexPath.row + 1])"
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.sizeToFit()
            let cellHeight = detailTagsCollectionView.frame.height // 셀의 높이 설정
            let cellWidth = label.frame.width + 8
            return CGSize(width: cellWidth, height: cellHeight)
            
        default:
            return .zero
        }
    }
    
}


// MARK: - ActionSheet, Alert
extension DetailViewController {

    func showEditActionSheet() {
        let actionSheet = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
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
        let deleteAlert = UIAlertController(title: "앨범 삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
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
