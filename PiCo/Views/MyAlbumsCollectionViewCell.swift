//
//  MyAlbumsCollectionViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift
import FirebaseStorage
import Kingfisher

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
        thumnailImageView.contentMode = .scaleAspectFill
        thumnailImageView.layer.cornerRadius = 4
        thumnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thumnailImageView.layer.masksToBounds = true
    }
    
    func setData(album: AlbumModel) {
        fetchImage(albumID: album.albumID)
        postURL = album.albumURL
        creationTimeLabel.text = album.getCreationTimeStr()
        tagLabel.text = "#\(album.tag)"
        dDayLabel.text = "D-\(album.getDDay())"
    }
    
    func fetchImage(albumID: String) {
        print("\(type(of: self)) - \(#function)")
        
        let albumImagesRef = Storage.storage().reference().child(albumID).child("1.jpeg")
        albumImagesRef.downloadURL {(url, error) in
            if let url = url, error == nil {
                print("\(url)")
                self.thumnailImageView.kf.setImage(with: url)
            } else {
                print("\(type(of: self)) - \(#function) 실패")
            }
        }
    }


}
