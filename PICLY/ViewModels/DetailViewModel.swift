//
//  DetailViewModel.swift
//  PICLY
//
//  Created by JDeoks on 4/5/24.
//

import Foundation
import RxSwift

class DetailViewModel {
    
    var album: AlbumModel?
    
    let deleteAlbumDone = PublishSubject<String>()
    let deleteAlbumFailed = PublishSubject<String>()

    func deleteAlbum() {
        print("\(type(of: self)) - \(#function)")
        guard let album = album else {
            self.deleteAlbumFailed.onNext("선택된 앨범 없음")
            return
        }

        DataManager.shared.deleteAlbum(albumID: album.albumID) { result in
            switch result {
            case .success():
                self.deleteAlbumDone.onNext(self.album?.albumID ?? "")
            case .failure(let error):
                self.deleteAlbumFailed.onNext(error.localizedDescription)
            }
        }

    }
}
