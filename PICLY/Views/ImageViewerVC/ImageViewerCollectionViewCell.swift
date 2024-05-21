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
    @IBOutlet var hStackView: UIStackView!
    @IBOutlet var vStackView: UIStackView!
    
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
        imageViewerScrollView.clipsToBounds = false
        imageViewerScrollView.alwaysBounceVertical = false
        imageViewerScrollView.alwaysBounceHorizontal = false
        imageViewerScrollView.minimumZoomScale = 1.0
        imageViewerScrollView.maximumZoomScale = 10
        imageViewerScrollView.delegate = self
        
        // imageViewerImageView
        imageViewerImageView.clipsToBounds = false
    }
    
}

extension ImageViewerCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageViewerImageView
    }
    
    // https://velog.io/@jxxnnee/Swift-CollectionView%EB%A1%9C-ImagePager%EB%A7%8C%EB%93%A4%EA%B8%B0-2
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let imageView = imageViewerImageView else { return }
        guard let image = imageView.image else { return }
        let zoomScale = scrollView.zoomScale
        
        if zoomScale > 1 {
            let ratioW = imageView.frame.width / image.size.width
            let ratioH = imageView.frame.height / image.size.height
            /// 이미지가 이미지 뷰에 접하는 부분의 비율
            let ratio = min(ratioW, ratioH)
            
            /// aspectFit으로 들어간 이미지의 실제 크기
            let imageWidth = image.size.width * ratio
            let imageHeight = image.size.height * ratio
            
            /// (이미지의 가로길이 * 현재 줌 스케일) 크기가
            /// 이미지뷰의 가로 길이보다 큰지 여부를 가리는 조건식
            print(" 원래 이미지 가로 세로: \(imageWidth), \(imageHeight)\n확대된 실제 이미지 가로 세로: \(imageWidth * zoomScale) \(imageHeight * zoomScale) \n 확대된 이미지뷰 가로 세로 : \(self.imageViewerImageView.frame) \n콘텐츠뷰\(scrollView.contentSize)")
            
            var insetW = 0.0
            if imageWidth * zoomScale > imageView.frame.width {
                //
                insetW = (imageWidth - imageView.frame.width) / 2
            } else {
                insetW = (scrollView.frame.width - imageView.frame.width) / 2
            }
            var insetH = 0.0
            var topInset = 0.0
            var bottomInset = 0.0
            if imageHeight * zoomScale > imageView.frame.height {
                insetH = (imageHeight - imageView.frame.height) / 2
                if ratioH > ratioW {
                    print("InsetH + safeAreaTopInset()")
                    topInset = insetH + safeAreaTopInset()
                    bottomInset = insetH + safeAreaBottomInset()
                } else {
                    topInset = insetH
                    bottomInset = insetH
                }
                
            } else {
                insetH = (scrollView.frame.height - imageView.frame.height) / 2
            }
            
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: insetW, bottom: bottomInset, right: insetW)
        } else {
            scrollView.contentInset = .zero
        }
    }
    
    func safeAreaTopInset() -> CGFloat {
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)
        
        let topPadding = window?.safeAreaInsets.top
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return topPadding ?? statusBarHeight
    }

    func safeAreaBottomInset() -> CGFloat {
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)
        
        let bottomPadding = window?.safeAreaInsets.bottom
        return bottomPadding ?? 0.0
    }

}
