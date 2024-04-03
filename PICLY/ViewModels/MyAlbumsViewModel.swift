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
    
    ///updateMyAlbums() -> MyAlbumsViewController
    let updateMyAlbumsDone = PublishSubject<Void>()
    
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
            self.updateMyAlbumsDone.onNext(())
        }
    }

}
