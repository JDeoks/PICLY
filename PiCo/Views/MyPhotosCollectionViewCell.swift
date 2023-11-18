//
//  MyPhotosCollectionViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit

class MyPhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var rootStackView: UIStackView!
    @IBOutlet var thumnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        rootStackView.layer.cornerRadius = 4
        thumnailImageView.layer.cornerRadius = 4
        thumnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thumnailImageView.layer.masksToBounds = true
    }
}
