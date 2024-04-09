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
    @IBOutlet var imageViewerCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imageViewerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
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
    
    // MARK: - action
    private func action() {
        closeButton.rx.tap
            .subscribe { _ in
                self.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
    }
    
}

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
//        
//        guard let album = self.album else {
//            print("\(type(of: self)) - \(#function) album: nil")
//            return CGSize(width: 0, height: 0)
//        }
//        
//        let width = collectionView.bounds.size.width
//        let height = width * CGFloat(album.getImageAspectRatio(index: indexPath.row))
//        return CGSize(width: width, height: height)
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
    
}
