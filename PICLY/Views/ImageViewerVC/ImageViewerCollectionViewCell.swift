//
//  ImageViewerCollectionViewCell.swift
//  PICLY
//
//  Created by JDeoks on 4/7/24.
//

import UIKit
import Kingfisher

class ImageViewerCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewerScrollView: UIScrollView!
    @IBOutlet var imageViewerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initUI()
    }
    
    func setData(album: AlbumModel?, indexPath: IndexPath) {
        guard let album = album else {
            print("\(type(of: self)) - \(#function) album: nil")
            return
        }
        let imageURL = album.imageURLs[indexPath.row]
        imageViewerImageView.kf.indicatorType = .activity
        imageViewerImageView.kf.setImage(with: imageURL)
        
        
    }
    
    private func initUI() {
        // imageViewerScrollView
        imageViewerScrollView.alwaysBounceVertical = false
        imageViewerScrollView.alwaysBounceHorizontal = false
        imageViewerScrollView.minimumZoomScale = 1.0
        imageViewerScrollView.maximumZoomScale = 2.5
        imageViewerScrollView.delegate = self
    }
    
}

extension ImageViewerCollectionViewCell: UIScrollViewDelegate {
      func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        self.imageViewerImageView
      }
}
