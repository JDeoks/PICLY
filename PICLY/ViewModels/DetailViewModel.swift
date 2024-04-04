//
//  DetailViewModel.swift
//  PICLY
//
//  Created by JDeoks on 4/5/24.
//

import Foundation

class DetailViewModel {
    
    var album: AlbumModel?
    var albumURL: URL?
    
    func deleteAlbum() {
        DataManager.shared.deleteAlbum(albumID: "8gkQOdOfUHao2QuttWdG") { result in
            print("8gkQOdOfUHao2QuttWdG")
            switch result {
            case .success():
                print("삭제 성공")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }
}
