//
//  DetailImagesTableViewCell.swift
//  PiCo
//
//  Created by JDeoks on 1/4/24.
//

import UIKit
import SnapKit
import Kingfisher

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
        detailImageView.image = nil
    }
    
    func initUI() {
        print("\(type(of: self)) - \(#function)")

        // detailImageView
        detailImageView.layer.cornerRadius = 4
//        detailImageView.alpha = 0
    }
    
    func setData(album: AlbumModel, indexPath: IndexPath) {
        print("\(type(of: self)) - \(#function)")

        let imageURL = album.imageURLs[indexPath.row]
        detailImageView.kf.indicatorType = .activity
        detailImageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
    }
}
