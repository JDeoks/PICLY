//
//  MyAlbumsDefaultCollectionViewCell.swift
//  PiCo
//
//  Created by JDeoks on 1/9/24.
//

import UIKit

class MyAlbumsDefaultCollectionViewCell: UICollectionViewCell {
    
    enum State: String {
        case empty = "업로드한 앨범이 없습니다.\n+ 버튼을 눌러 앨범을 업로드하고 공유해보세요."
        case noSearchResults = "검색 결과가 없습니다."
    }

    @IBOutlet var guideLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(state: State) {
        guideLabel.text = state.rawValue
    }

}
