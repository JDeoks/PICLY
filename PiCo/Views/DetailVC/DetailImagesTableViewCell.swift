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
    
    func setData(album: AlbumModel, indexPath: IndexPath) {
        print("\(type(of: self)) - \(#function)")

        detailImageView.kf.indicatorType = .activity
        detailImageView.kf.setImage(with: album.imageURLs[indexPath.row]) { result in
            switch result {
            case .success(let value):
                print("이미지 성공")
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2) {
                        print("이미지 알파")
                        self.detailImageView.alpha = 1.0
                    }
                    self.layoutIfNeeded()
                }

            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }
}
