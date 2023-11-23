//
//  SelectedImageCollectionViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/21/23.
//

import UIKit

class SelectedImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        // imageView
        imageView.layer.cornerRadius = 4
//        imageView.contentMode = .top
    }

}
