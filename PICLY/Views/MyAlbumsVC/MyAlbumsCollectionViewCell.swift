//
//  MyAlbumsCollectionViewCell.swift
//  PICLY
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift
import FirebaseStorage
import Kingfisher
import SkeletonView

class MyAlbumsCollectionViewCell: UICollectionViewCell {
    
    var albumURL = PICLYConstants.defaultRootURL
    var thumbnailURL: URL!
    var imageURLs: [URL] = []
    var disposeBag = DisposeBag()
    
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var copyLinkButton: UIButton!
    @IBOutlet var tagLabelContainerView: UIStackView!
    @IBOutlet var creationTimeLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var dDayLabel: UILabel!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var multiImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // view
        self.stopSkeletonAnimation()
        self.hideSkeleton()
        
        // thumnailImageView
        thumnailImageView.image = nil
        thumnailImageView.kf.cancelDownloadTask()
        thumnailImageView.stopSkeletonAnimation()
        thumnailImageView.hideSkeleton()
        
        // dDayLabel
        dDayLabel.textColor = ColorManager.shared.secondText
        
        // copyLinkButton
        copyLinkButton.isHidden = false
        // gradientView
        gradientView.isHidden = false
        
        // multiImageView
        multiImageView.isHidden = false
        
        disposeBag = DisposeBag()
    }
    
    func initUI() {
        // view
        self.layer.cornerRadius = 4
        self.isSkeletonable = true

        // thumnailImageView
        thumnailImageView.isSkeletonable = true
        thumnailImageView.contentMode = .scaleAspectFill
        thumnailImageView.layer.cornerRadius = 4
        thumnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thumnailImageView.layer.masksToBounds = true
        
        // gradientView
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [CGColor(red: 0, green: 0, blue: 0, alpha: 0.4), CGColor(red: 0, green: 0, blue: 0, alpha: 0.2), CGColor(red: 0, green: 0, blue: 0, alpha: 0)]
        gradient.frame = gradientView.bounds
        gradient.locations = [0.0 ,0.6, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientView.layer.addSublayer(gradient)
        
        // creationTimeLabel
        creationTimeLabel.isSkeletonable = true
        creationTimeLabel.linesCornerRadius = 2
        
        // tagLabelContainerView
        tagLabelContainerView.isSkeletonable = true
        
        // tagLabel
        tagLabel.isSkeletonable = true
        tagLabel.linesCornerRadius = 2
    }
    
    func setData(album: AlbumModel) {
        // SkeletonView
        if album.isSkeleton {
            let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 1, autoreverses: true)
            self.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.lightGray, .gray]), animation: skeletonAnimation, transition: .none)
            copyLinkButton.isHidden = true
            gradientView.isHidden = true
            multiImageView.isHidden = true
            return
        }
        
        // thumnailImageView
        let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 1, autoreverses: true)
        thumnailImageView.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.lightGray, .gray]), animation: skeletonAnimation, transition: .none)
        
        // albumURL
        let rootURL: URL = ConfigManager.shared.getRootURLFromLocal()
        albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(album.albumID)
        
        // creationTimeLabel
        creationTimeLabel.text = album.getCreationTimeStr()
        
        // tagLabel
        tagLabel.text = album.tags.isEmpty ? "" : "#\(album.tags[0])"
        
        // dDayLabel
        if album.expireTime < Date() {
            dDayLabel.textColor = ColorManager.shared.warnRed
            dDayLabel.text = "만료"
        } else {
            let dDay = album.getDDay()
            dDayLabel.text = dDay == 0 ? "D-DAY" : "D-\(dDay)"
        }
        
        // thumbnailURL
        thumbnailURL = album.thumbnailURL
        
        // multiImageView
        multiImageView.isHidden = album.imageCount > 1 ? false : true
        
        // others
        fetchThumbnail(albumID: album.albumID)
    }
    
    func fetchThumbnail(albumID: String) {        
        thumnailImageView.kf.setImage(with: thumbnailURL, placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error.errorDescription)
                
            }
            self.thumnailImageView.stopSkeletonAnimation()
            self.thumnailImageView.hideSkeleton()
        }
    }

}
