//
//  ImageViewerViewController.swift
//  PICLY
//
//  Created by JDeoks on 4/7/24.
//

import UIKit
import RxSwift
import Kingfisher

class ImageViewerViewController: UIViewController {
    
    var album: AlbumModel?
    var indexPath = IndexPath(row: 0, section: 0)
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var saveImageButton: UIButton!
    @IBOutlet var imageIndexLabel: UILabel!
    @IBOutlet var imageViewerCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imageViewerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        updateImageIndex()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let flowLayout = imageViewerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // 현재 뷰의 크기에 맞게 셀 크기 조정
        flowLayout.itemSize = imageViewerCollectionView.bounds.size
        // 레이아웃을 무효화하고 갱신
        flowLayout.invalidateLayout()
        // 레이아웃 변경사항즉시 업데이트
        imageViewerCollectionView.layoutIfNeeded()
    }
    
    func setData(album: AlbumModel?, indexPath: IndexPath) {
        print("\(type(of: self)) - \(#function)")
        
        self.album = album
        self.indexPath = indexPath
    }
    
    // MARK: - initUI
    private func initUI() {
        imageViewerCollectionView.dataSource = self
        imageViewerCollectionView.delegate = self
        let imageViewerCollectionViewCell = UINib(nibName: "ImageViewerCollectionViewCell", bundle: nil)
        imageViewerCollectionView.register(imageViewerCollectionViewCell, forCellWithReuseIdentifier: "ImageViewerCollectionViewCell")
        let imageViewerFlowLayout = UICollectionViewFlowLayout()
        imageViewerFlowLayout.scrollDirection = .horizontal
        imageViewerCollectionView.collectionViewLayout = imageViewerFlowLayout
        imageViewerCollectionView.isPagingEnabled = true
    }
    
    // MARK: - initData
    private func initData() {
        updateImageIndex()
    }
    
    // MARK: - action
    private func action() {
        closeButton.rx.tap
            .subscribe { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        saveImageButton.rx.tap
            .subscribe { _ in
                let width = self.imageViewerCollectionView.frame.width
                let index = Int(self.imageViewerCollectionView.contentOffset.x / width)
                guard let cell = self.imageViewerCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageViewerCollectionViewCell else {
                    print("saveImageButton.rx.tap - cell: nil")
                    self.showToast(message: "이미지 저장 실패.")
                    return
                }
                guard let image = cell.imageViewerImageView.image else {
                    print("saveImageButton.rx.tap - image: nil")
                    self.showToast(message: "이미지 저장 실패.")
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
            }
    }
    
    /// 이미지 저장 완료 핸들러
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        print("\(type(of: self)) - \(#function)")

        if let error = error {
            print(error.localizedDescription)
            showImageAccessAlert()
        } else {
            self.showToast(message: "이미지가 저장되었습니다.")
        }
    }
    
    /// 이미지 인덱스 업데이트
    private func updateImageIndex() {
        let width = imageViewerCollectionView.frame.width
        let currentIndex = Int(imageViewerCollectionView.contentOffset.x / width)
        imageIndexLabel.text = "\(currentIndex + 1) / \(album?.imageURLs.count ?? 0)"
    }
    
}

// MARK: - UICollectionView
extension ImageViewerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let album = self.album else {
            print("\(type(of: self)) - \(#function) album: nil")
            return 0
        }
        return album.imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageViewerCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewerCollectionViewCell", for: indexPath) as! ImageViewerCollectionViewCell
        cell.setData(album: self.album, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageViewerCollectionViewCell else {
            return
        }
        cell.imageViewerScrollView.zoomScale = 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // 섹션 간의 수직 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // 섹션 내 아이템 간의 수평 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let newIndex = Int(scrollView.contentOffset.x / width)
        updateImageIndex()
    }
    
}

extension ImageViewerViewController {
    
    /// 앨범 권한 필요 Alert
    func showImageAccessAlert() {
        let sheet = UIAlertController(title: "앨범 권한 필요", message: "앨범 접근 권한이 부여되지 않았습니다.\n디바이스 설정에서 변경해주세요.", preferredStyle: .alert)
        let moveAction = UIAlertAction(title: "이동", style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        sheet.addAction(moveAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
}
