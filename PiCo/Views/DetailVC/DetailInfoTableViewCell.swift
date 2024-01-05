//
//  DetailInfoTableViewCell.swift
//  PiCo
//
//  Created by JDeoks on 1/4/24.
//

import UIKit
import RxSwift

class DetailInfoTableViewCell: UITableViewCell {
    
    var album: AlbumModel!
    
    var disposeBag = DisposeBag()
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var copyLinkButton: UIButton!
    @IBOutlet var firstTagLabel: UILabel!
    @IBOutlet var tagsCollectionView: UICollectionView!
    @IBOutlet var viewCountLabel: UILabel!
    @IBOutlet var remainTimeLabel: UILabel!
    
    override func awakeFromNib() {
        print("\(type(of: self)) - \(#function)")
        super.awakeFromNib()

        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func initUI() {
        // tagsCollectionView
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        let tagsCollectionViewCell = UINib(nibName: "DetailTagsCollectionViewCell", bundle: nil)
        tagsCollectionView.register(tagsCollectionViewCell, forCellWithReuseIdentifier: "DetailTagsCollectionViewCell")
        let tagsFlowLayout = UICollectionViewFlowLayout()
        tagsFlowLayout.scrollDirection = .horizontal
        tagsCollectionView.collectionViewLayout = tagsFlowLayout
    }
    
    func setData(album: AlbumModel) {
        print("\(type(of: self)) - \(#function)")

        // dateLabel
        dateLabel.text = album.getCreationTimeStr()
        
        // tagLabel
        if album.tags.isEmpty {
            firstTagLabel.isHidden = true
        } else {
            firstTagLabel.text = "#\(album.tags[0])"
        }
        
        // detailTagsCollectionView
        if album.tags.count <= 1 {
            tagsCollectionView.isHidden = true
        }
        
        // viewCountLabel
        viewCountLabel.text = "\(album.viewCount)"
        
        // remainTimeLabel
        remainTimeLabel.text = album.getTimeRemainingStr()
        
        //album
        self.album = album
    }
    
    
    
    
}

extension DetailInfoTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(type(of: self)) - \(#function)")

        let tagCount = album.tags.count - 1
        return tagCount > 0 ? tagCount : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("\(type(of: self)) - \(#function)")

        let cell = tagsCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailTagsCollectionViewCell", for: indexPath) as! DetailTagsCollectionViewCell
        cell.tagLabel.text = "#\(album.tags[indexPath.row + 1])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("\(type(of: self)) - \(#function)")

        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("\(type(of: self)) - \(#function)")

        // 사이즈 계산용 라벨
        let label = UILabel()
        label.text = "#\(album.tags[indexPath.row + 1])"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.sizeToFit()
        let cellHeight = tagsCollectionView.frame.height // 셀의 높이 설정
        let cellWidth = label.frame.width + 8
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

