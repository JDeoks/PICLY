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
    @IBOutlet var gradientView: UIView!
    @IBOutlet var multiImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dDayLabel.textColor = UIColor(named: "SecondText")
        thumnailImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    func initUI() {
        // view
        self.layer.cornerRadius = 4
        
        // thumnailImageView
        thumnailImageView.contentMode = .scaleAspectFill
        thumnailImageView.layer.cornerRadius = 4
        thumnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thumnailImageView.layer.masksToBounds = true
        
        // gradientView
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [CGColor(red: 0, green: 0, blue: 0, alpha: 0.8), CGColor(red: 0, green: 0, blue: 0, alpha: 0.5), CGColor(red: 0, green: 0, blue: 0, alpha: 0)]
        gradient.frame = gradientView.bounds
        gradient.locations = [0.0 ,0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientView.layer.addSublayer(gradient)
    }
    
    func setData(album: AlbumModel) {
        // albumURL
        let rootURL: URL = ConfigManager.shared.getRootURL()
        albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(album.albumID)
        
        // creationTimeLabel
        creationTimeLabel.text = album.getCreationTimeStr()
        
        // tagLabel
        tagLabel.text = album.tags.isEmpty ? "" : "#\(album.tags[0])"
        
        // dDayLabel
        
        if album.expireTime < Date() {
            dDayLabel.textColor = UIColor(named: "warnRed")
            dDayLabel.text = "만료"
        } else {
            let dDay = album.getDDay()
            dDayLabel.text = dDay == 0 ? "D-DAY" : "D-\(dDay)"
        }
        
        // thumbnailURL
        thumbnailURL = album.thumbnailURL
        let cnt = album.imageCount
        
        if album.imageCount > 1 {
            multiImageView.isHidden = false
        } else {
            multiImageView.isHidden = true
        }
        
        // others
        fetchThumbnail(albumID: album.albumID)
    }
    
    func fetchThumbnail(albumID: String) {
        print("\(type(of: self)) - \(#function)")
        
        thumnailImageView.kf.indicatorType = .activity
        thumnailImageView.kf.setImage(with: thumbnailURL, placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil)
    }

}
