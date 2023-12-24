//
//  TagsCollectionViewCell.swift
//  PiCo
//
//  Created by JDeoks on 12/23/23.
//

import UIKit
import RxSwift

class TagsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var tagTextField: UILabel!
    @IBOutlet var deleteTagButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func initUI() {
        self.layer.cornerRadius = 4
    }

}
