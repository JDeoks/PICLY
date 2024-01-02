//
//  DetailImagesTableViewCell.swift
//  PiCo
//
//  Created by JDeoks on 1/2/24.
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

        detailImageView.layer.cornerRadius = 4
        detailImageView.alpha = 0
    }
    
    func initData(album: AlbumModel, indexPath: IndexPath, updateTableView: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        detailImageView.kf.indicatorType = .activity
        detailImageView.kf.setImage(with: album.imageURLs[indexPath.row]) { result in
            switch result {
            case .success(let value):
                print("setImage")
                let image = value.image
                let aspectRatio = image.size.width / image.size.height
                // ImageView의 비율 조정
                self.detailImageView.snp.remakeConstraints { make in
                    make.width.equalTo(self.detailImageView.snp.height).multipliedBy(aspectRatio)
                }
                self.layoutIfNeeded()
                
                updateTableView()
                
                UIView.animate(withDuration: 0.2) {
                    self.detailImageView.alpha = 1.0
                    self.layoutIfNeeded()
                }
                
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }
    
}
