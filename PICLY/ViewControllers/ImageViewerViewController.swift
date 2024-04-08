//
//  ImageViewerViewController.swift
//  PICLY
//
//  Created by JDeoks on 4/7/24.
//

import UIKit

class ImageViewerViewController: UIViewController {

    @IBOutlet var imageViewerCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageViewerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageViewerCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewerCollectionViewCell", for: indexPath)
        return cell
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
    
}
