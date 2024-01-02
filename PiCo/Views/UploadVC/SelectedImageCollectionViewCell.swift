//
//  SelectedImageCollectionViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/21/23.
//

import UIKit
import RxSwift

class SelectedImageCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func initUI() {
        // imageView
        imageView.layer.cornerRadius = 4
//        imageView.contentMode = .top
    }

}
