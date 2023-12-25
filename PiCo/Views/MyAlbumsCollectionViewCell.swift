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
        fetchThumbnail(albumID: album.albumID)
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
    
    func fetchThumbnail(albumID: String) {
        print("\(type(of: self)) - \(#function)")

        thumnailImageView.kf.indicatorType = .activity
        let storageRef = Storage.storage().reference().child(albumID)
        fetchImage(from: storageRef, withName: "thumbnail.jpeg")
    }

    private func fetchImage(from storageRef: StorageReference, withName fileName: String) {
        print("\(type(of: self)) - \(#function)", fileName)
        
        storageRef.child(fileName).downloadURL { [weak self] url, error in
            guard let url = url, error == nil else {
                print("Failed to fetch \(fileName): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self?.thumnailImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
        }
    }

}
