//
//  MyAlbumsViewModel.swift
//  PICLY
//
//  Created by JDeoks on 4/4/24.
//

import Foundation
import RxSwift

class MyAlbumsViewModel {
    
    var myAlbums: [AlbumModel] = [AlbumModel(), AlbumModel(), AlbumModel()]
    
    /// fetchMyAlbums() -> MyAlbumsViewController
    let fetchMyAlbumsDone = PublishSubject<Void>()
    let deleteAlbumDone = PublishSubject<String>()
    let deleteAlbumFailed = PublishSubject<String>()
    
    /// 로컬에 저장된 사용자의 앨범을 fetch
    func fetchMyAlbums() {
        print("\(type(of: self)) - \(#function)")

        DataManager.shared.fetchMyAlbums { querySnapshot in
            guard let querySnapshot = querySnapshot else {
                print("\(#function) 실패")
                return
            }
            self.myAlbums.removeAll()
            for document in querySnapshot.documents {
                let album = AlbumModel(document: document)
                self.myAlbums.append(album)
            }
            self.fetchMyAlbumsDone.onNext(())
        }
    }

    func deleteAlbum(album: AlbumModel?) {
        print("\(type(of: self)) - \(#function)")
        
        guard let album = album else {
            self.deleteAlbumFailed.onNext("선택된 앨범 없음")
            return
        }

        DataManager.shared.deleteAlbum(albumID: album.albumID) { result in
            switch result {
            case .success():
                self.deleteAlbumDone.onNext(album.albumID)
            case .failure(let error):
                self.deleteAlbumFailed.onNext(error.localizedDescription)
            }
        }

    }

}
