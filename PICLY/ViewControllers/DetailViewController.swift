//
//  DetailViewController.swift
//  PICLY
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import FirebaseFirestore
import FirebaseStorage

class DetailViewController: UIViewController {
    
    let albumsCollection = Firestore.firestore().collection("Albums")
    var album: AlbumModel!
    var albumURL: URL?
    
    let deleteAlbumDone = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))

    @IBOutlet var backButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
        action()
        bind()
    }
    
    func initUI() {
        // detailTableView
        detailTableView.dataSource = self
        detailTableView.delegate = self
        let detailInfoTableCell = UINib(nibName: "DetailInfoTableViewCell", bundle: nil)
        detailTableView.register(detailInfoTableCell, forCellReuseIdentifier: "DetailInfoTableViewCell")
        let detailImagesTableCell = UINib(nibName: "DetailImagesTableViewCell", bundle: nil)
        detailTableView.register(detailImagesTableCell, forCellReuseIdentifier: "DetailImagesTableViewCell")
    }
    
    func initData() {
        // albumURL
        let rootURL: URL = ConfigManager.shared.getRootURLFromLocal()
        albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(album.albumID)
    }
    
    func action() {
        backButton.rx.tap
            .subscribe { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        editButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.showEditActionSheet()
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
//        deleteAlbumDone
//            .subscribe { _ in
//
//            }
//            .disposed(by: disposeBag)
    }

}

// MARK: - UITableView
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        print("\(type(of: self)) - \(#function)")

        switch tableView {
        case detailTableView:
            switch section {
            case 0:
                return 1
            
            default:
                print("album.imageCount", album.imageCount)
                print("album.imageURLs.count", album.imageURLs.count)
                return album.imageURLs.count
            }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\(type(of: self)) - \(#function)")

        switch indexPath.section {
        case 0:
            let cell = detailTableView.dequeueReusableCell(withIdentifier: "DetailInfoTableViewCell", for: indexPath) as! DetailInfoTableViewCell
            cell.setData(album: album)
            cell.copyLinkButton.rx.tap
                .subscribe { _ in
                    HapticManager.shared.triggerImpact()
                    UIPasteboard.general.url = self.albumURL
                    self.showToast(message: "링크가 복사되었습니다.", keyboardHeight: 0)
                }
                .disposed(by: cell.disposeBag)
            cell.selectionStyle = .none
            return cell
            
        default:
            let cell = detailTableView.dequeueReusableCell(withIdentifier: "DetailImagesTableViewCell", for: indexPath) as! DetailImagesTableViewCell
            cell.setData(album: album, indexPath: indexPath)
            cell.selectionStyle = .none

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("\(type(of: self)) - \(#function)")

        switch tableView {
        case detailTableView:
            switch indexPath.section {
            case 0:
                return UITableView.automaticDimension
            
            default:
                let verticalPadding = CGFloat(8 * 2)
                let horizontalPadding = CGFloat(16 * 2)
                let aspectRatio = CGFloat(album.getImageAspectRatio(index: indexPath.row))
                let height = (aspectRatio * (tableView.frame.width - horizontalPadding) + verticalPadding)
                return height
            }
            
        default:
            return 0
        }
    }
    
    
    
}

// MARK: - UICollectionView
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return DetailTagsCollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
}

// MARK: - ActionSheet, Alert
extension DetailViewController {

    private func showEditActionSheet() {
        let actionSheet = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        
//        actionSheet.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
//            print("정보 수정")
//            let editVC = self.storyboard?.instantiateViewController(identifier: "EditViewController") as! EditViewController
//            self.navigationController?.pushViewController(editVC, animated: true)
//        }))

        actionSheet.addAction(UIAlertAction(title: "공유", style: .default, handler: { _ in
            guard let url = self.albumURL else {
                return
            }
            self.shareURL(url: url)
        }))
        actionSheet.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.showDeleteConfirmationAlert()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /// 앨범 삭제 확인 alert
    private func showDeleteConfirmationAlert() {
        let deleteAlert = UIAlertController(title: "앨범 삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.loadingView.loadingLabel.text = ""
            self.view.addSubview(self.loadingView)
            self.deleteAlbum()
        })
        deleteAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    /// 앨범 삭제 로직
    private func deleteAlbum() {
        print("\(type(of: self)) - \(#function)")

        deleteAlbumDoc {
            self.deleteAlbumImage {
                DataManager.shared.albumDeleted.onNext(self.album.albumID)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func deleteAlbumDoc(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        albumsCollection.document(album.albumID).delete() { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
                self.showToast(message: "삭제 실패", keyboardHeight: 0)
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully removed!")
                completion()
            }
        }
    }
    
    private func deleteAlbumImage(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let albumImagesRef = Storage.storage().reference().child(album.albumID)
        albumImagesRef.listAll { (result, error) in
            if let error = error {
                print("Error in listing files: \(error)")
                self.loadingView.removeFromSuperview()
                self.showToast(message: "삭제 실패", keyboardHeight: 0)
                return
            }
            guard let result = result else {
                print("\(#function) result 없음")
                self.loadingView.removeFromSuperview()
                self.showToast(message: "삭제 실패", keyboardHeight: 0)
                return
            }
            let dispatchGroup = DispatchGroup()
            
            for item in result.items {
                dispatchGroup.enter()
                item.delete { error in
                    if let error = error {
                        print("Error deleting file: \(error)")
                    } else {
                        print("File deleted successfully")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.loadingView.removeFromSuperview()
                completion()
            }
        }
    }
}

// MARK: - UIActivityViewController
extension DetailViewController {
    
    private func shareURL(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        // 아이패드에서 실행될 경우
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}
