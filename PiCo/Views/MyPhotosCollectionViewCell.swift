//
//  MyPhotosCollectionViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift

class MyPhotosCollectionViewCell: UICollectionViewCell {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var rootStackView: UIStackView!
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var copyLinkButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
        action()
    }
    
    func initUI() {
        rootStackView.layer.cornerRadius = 4
        thumnailImageView.layer.cornerRadius = 4
        thumnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thumnailImageView.layer.masksToBounds = true
    }
    
    func action() {
        copyLinkButton.rx.tap
            .subscribe { _ in
                print("링크복사")
            }
            .disposed(by: disposeBag)
    }
}
