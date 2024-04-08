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
    
    let detailViewModel = DetailViewModel()
    
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
        detailViewModel.deleteAlbumDone
            .subscribe { deletedAlbumID in
                DataManager.shared.albumDeleted.onNext(deletedAlbumID)
                self.loadingView.removeFromSuperview()
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        detailViewModel.deleteAlbumFailed
            .subscribe { errorMSG in
                print("삭제 실패:\(errorMSG)")
                self.showToast(message: "앨범 삭제에 실패했습니다.")
            }
            .disposed(by: disposeBag)
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
                guard let album = detailViewModel.album else {
                    return 0
                }
                print("detailViewModel.album.imageCount:", album.imageCount, "album.imageURLs.count:", album.imageURLs.count)
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
            guard let album = detailViewModel.album else {
                print("\(type(of: self)) - \(#function) album 없음")
                return cell
            }
            cell.setData(album: album)
            cell.copyLinkButton.rx.tap
                .subscribe { _ in
                    HapticManager.shared.triggerImpact()
                    UIPasteboard.general.url = album.url
                    self.showToast(message: "링크가 복사되었습니다.", keyboardHeight: 0)
                }
                .disposed(by: cell.disposeBag)
            cell.selectionStyle = .none
            return cell
            
        default:
            let cell = detailTableView.dequeueReusableCell(withIdentifier: "DetailImagesTableViewCell", for: indexPath) as! DetailImagesTableViewCell
            guard let album = detailViewModel.album else {
                print("\(type(of: self)) - \(#function) album 없음")
                return cell
            }
            
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
                guard let album = detailViewModel.album else {
                    print("\(type(of: self)) - \(#function) album 없음")
                    return 0
                }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SceneManager.shared.presentImageViewerVC(vc: self)
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
        print("\(type(of: self)) - \(#function)")

        let actionSheet = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        
//        actionSheet.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
//            print("정보 수정")
//            let editVC = self.storyboard?.instantiateViewController(identifier: "EditViewController") as! EditViewController
//            self.navigationController?.pushViewController(editVC, animated: true)
//        }))

        actionSheet.addAction(UIAlertAction(title: "공유", style: .default, handler: { _ in
            guard let album = self.detailViewModel.album else {
                print("\(type(of: self)) - \(#function) album 없음")
                return
            }
            self.shareURL(url: album.url)
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
        print("\(type(of: self)) - \(#function)")

        
        let deleteAlert = UIAlertController(title: "앨범 삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            guard let album = self.detailViewModel.album else {
                print("\(type(of: self)) - \(#function) album 없음")
                
                return
            }
            self.loadingView.loadingLabel.text = ""
            self.view.addSubview(self.loadingView)
            self.detailViewModel.deleteAlbum()
        })
        deleteAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }

}

// MARK: - UIActivityViewController
extension DetailViewController {
    
    private func shareURL(url: URL) {
        print("\(type(of: self)) - \(#function)")

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
