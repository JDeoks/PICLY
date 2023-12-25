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
    
    var postURL = URL(string: "https://picoweb.vercel.app/")!
    
    var disposeBag = DisposeBag()
    
    @IBOutlet var thumnailImageView: UIImageView!
    @IBOutlet var copyLinkButton: UIButton!
    @IBOutlet var creationTimeLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var dDayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        thumnailImageView.image = nil
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
        let rootURL: URL = ConfigManager.shared.getRootURL()
        postURL = rootURL.appendingPathComponent("Album").appendingPathComponent(album.albumID)
        creationTimeLabel.text = album.getCreationTimeStr()
        if album.tags.isEmpty {
            tagLabel.text = "#"
        } else {
            tagLabel.text = "# \(album.tags[0])"
        }
        if album.getDDay() < 0 {
            dDayLabel.text = "D+\(-album.getDDay())"
        } else {
            dDayLabel.text = "D-\(album.getDDay())"
        }
        
    }
    
    func fetchImage(albumID: String) {
        print("\(type(of: self)) - \(#function)")
        
        thumnailImageView.kf.indicatorType = .activity
        let albumImagesRef = Storage.storage().reference().child(albumID).child("0.jpeg")
        albumImagesRef.downloadURL {(url, error) in
            if let url = url, error == nil {
                print("\(url)")
                self.thumnailImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
            } else {
                print("\(type(of: self)) - \(#function) 실패")
            }
        }
    }

}
