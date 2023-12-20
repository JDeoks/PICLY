//
//  MyAlbumsCollectionViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift

class MyAlbumsCollectionViewCell: UICollectionViewCell {
    
    var postURL: URL?
    
    var disposeBag = DisposeBag()
    
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var copyLinkButton: UIButton!
    @IBOutlet var creationTimeLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var dDayLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        // view
        self.layer.cornerRadius = 4
        // thumnailImageView
        thumnailImageView.layer.cornerRadius = 4
        thumnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thumnailImageView.layer.masksToBounds = true
    }
    
    func setData(album: AlbumModel) {
//        thumnailImageView.image
        postURL = album.albumURL
        creationTimeLabel.text = album.getCreationTimeStr()
        tagLabel.text = "#\(album.tag)"
        dDayLabel.text = "D-\(album.getDDay())"
        
    }

}
