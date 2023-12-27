//
//  DetailViewController.swift
//  PiCo
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
        bind()
    }
    
    func initUI() {
        // imageView
        imageView.layer.cornerRadius = 4
        imageView.alpha = 0
        
        // shareButton
        shareButton.layer.cornerRadius = 4
        shareButton.alpha = 0
        shareButton.isEnabled = false
        
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
        // dateLabel
        dateLabel.text = album.getCreationTimeStr()
        
        // tagLabel
        if album.tags.isEmpty {
            tagLabel.text = "#"
        } else {
            tagLabel.text = "#\(album.tags[0])"
        }
        
        // detailTagsCollectionView
        if album.tags.count <= 1 {
            detailTagsCollectionView.isHidden = true
        }
        
        // viewCountLabel
        viewCountLabel.text = "\(album.viewCount)"
        
        // remainTimeLabel
        remainTimeLabel.text = album.getTimeRemainingStr()
        
        // albumURL
        let rootURL: URL = ConfigManager.shared.getRootURL()
        albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(album.albumID)
        
        // others
        let storageRef = Storage.storage().reference().child(album.albumID)
        fetchImage()
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
        
        copyLinkButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                guard let url = self.albumURL else {
                    self.showToast(message: "링크 복사 실패")
                    return
                }
                UIPasteboard.general.url = url
                self.showToast(message: "링크가 복사되었습니다")
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        deleteAlbumDone
            .subscribe { _ in
                self.showToast(message: "삭제 성공")
                DataManager.shared.fetchAlbums()
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    func fetchImage() {
        print("\(type(of: self)) - \(#function)")
        
        imageView.kf.indicatorType = .activity
        
        self.imageView.kf.setImage(with: album.imageURLs[0], placeholder: nil, completionHandler: { result in
            switch result {
            case .success(let value):
                let image = value.image
                let aspectRatio = image.size.width / image.size.height
                // ImageView의 비율 조정
                self.imageView.snp.remakeConstraints { make in
                    make.width.equalTo(self.imageView.snp.height).multipliedBy(aspectRatio)
                }
                self.view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1.0
                    self.shareButton.alpha = 1.0
                    self.shareButton.isEnabled = true
                }
                
            case .failure(let error):
                print("Error loading image: \(error)")
            }
            
        })
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
            cell.tagLabel.text = "#\(album.tags[indexPath.row + 1])"
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
            // 사이즈 계산용 라벨
            let label = UILabel()
            label.text = "#\(album.tags[indexPath.row + 1])"
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
            self.loadingView.loadingLabel.text = ""
            self.view.addSubview(self.loadingView)
            self.deleteAlbum()
        })
        deleteAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteAlbum() {
        print("\(type(of: self)) - \(#function)")

        deleteAlbumDoc {
            self.deleteAlbumImage {
                self.deleteAlbumDone.onNext(())
            }
        }
    }
    
    func deleteAlbumDoc(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        
        albumsCollection.document(album.albumID).delete() { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
                // TODO: 앨범 삭제 실패 토스트
                self.showToast(message: "삭제 실패")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully removed!")
                completion()
            }
        }
    }
    
    func deleteAlbumImage(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let albumImagesRef = Storage.storage().reference().child(album.albumID)
        albumImagesRef.listAll { (result, error) in
            if let error = error {
                print("Error in listing files: \(error)")
                self.loadingView.removeFromSuperview()
                self.showToast(message: "삭제 실패")
                return
            }
            guard let result = result else {
                print("\(#function) result 없음")
                self.loadingView.removeFromSuperview()
                self.showToast(message: "삭제 실패")
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
