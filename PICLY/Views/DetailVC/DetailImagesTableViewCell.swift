//
//  DetailImagesTableViewCell.swift
//  PICLY
//
//  Created by JDeoks on 1/4/24.
//

import UIKit
import SnapKit
import Kingfisher
import SkeletonView

class DetailImagesTableViewCell: UITableViewCell {

    @IBOutlet var detailImageView: UIImageView!
    
    override func awakeFromNib() {
        print("\(type(of: self)) - \(#function)")

        super.awakeFromNib()
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // view
        self.stopSkeletonAnimation()
        self.hideSkeleton()
        
        // detailImageView
        detailImageView.image = nil
    }
    
    func setData(album: AlbumModel, indexPath: IndexPath) {
        print("\(type(of: self)) - \(#function)")

        let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 1, autoreverses: true)
        self.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.lightGray, .gray]), animation: skeletonAnimation, transition: .none)
        
        let imageURL = album.imageURLs[indexPath.row]
        detailImageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))]) { _ in
            self.stopSkeletonAnimation()
            self.hideSkeleton()
        }
    }
    
    // MARK: - initUI
    private func initUI() {
        print("\(type(of: self)) - \(#function)")
        
        // view
        self.isSkeletonable = true

        // detailImageView
        detailImageView.isSkeletonable = true
        detailImageView.layer.cornerRadius = 4
    }
    
}
