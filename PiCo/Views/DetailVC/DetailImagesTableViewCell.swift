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
    
    func initUI() {
        print("\(type(of: self)) - \(#function)")

        // detailImageView
        detailImageView.layer.cornerRadius = 4
        detailImageView.alpha = 0
    }
    
    func setData(album: AlbumModel, indexPath: IndexPath,  updateTableView: @escaping (CGFloat) -> Void) {
        print("\(type(of: self)) - \(#function)")

        detailImageView.kf.indicatorType = .activity
        detailImageView.kf.setImage(with: album.imageURLs[indexPath.row - 1]) { result in
            switch result {
            case .success(let value):
                let image = value.image
                let newHeight = self.detailImageView.frame.width * image.size.height / image.size.width
                self.layoutIfNeeded()
                updateTableView(newHeight)
                UIView.animate(withDuration: 0.2) {
                    self.detailImageView.alpha = 1.0
                }

            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }
}
