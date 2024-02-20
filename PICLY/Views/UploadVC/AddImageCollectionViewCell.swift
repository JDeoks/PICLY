//
//  AddImageCollectionViewCell.swift
//  PICLY
//
//  Created by 서정덕 on 11/21/23.
//

import UIKit

class AddImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var plusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    func initUI() {
        containerView.layer.cornerRadius = 8
    }
}
