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
    
    var albumURL = URL(string: "https://picoweb.vercel.app/")!
    var thumbnailURL: URL!
    var imageURLs: [URL] = []
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
        // albumURL
        let rootURL: URL = ConfigManager.shared.getRootURL()
        albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(album.albumID)
        
        // creationTimeLabel
        creationTimeLabel.text = album.getCreationTimeStr()
        
        // tagLabel
        tagLabel.text = album.tags.isEmpty ? "#" : "# \(album.tags[0])"
        
        // dDayLabel
        if album.getDDay() < 0 {
            dDayLabel.text = "D+\(-album.getDDay())"
        } else {
            dDayLabel.text = "D-\(album.getDDay())"
        }
        
        // thumbnailURL
        thumbnailURL = album.thumbnailURL
        
        // others
        fetchThumbnail(albumID: album.albumID)
    }
    
    func fetchThumbnail(albumID: String) {
        print("\(type(of: self)) - \(#function)")
        
        thumnailImageView.kf.indicatorType = .activity
        thumnailImageView.kf.setImage(with: thumbnailURL, placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil)
    }

}
