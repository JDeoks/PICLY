//
//  UploadViewModel.swift
//  PiCo
//
//  Created by JDeoks on 12/23/23.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import SwiftDate
import FirebaseFirestore
import FirebaseStorage

class UploadViewModel {
    
    let albumCollection = Firestore.firestore().collection("Albums")
    /// 업로드 성공한 앨범의 URL
    var albumURL: URL?
    /// 선택한 사진 배열  param1: index, param2: image
    var imageTuples: [(Int, UIImage)] = []
    var thumbnailURL: URL?
    /// 앨범에 추가할 이미지 접근 url
    var imageURLs: [(Int, URL)] = []
    /// param1: index, param2: height, param3: width
    var imageSizeTuples: [(Int, CGFloat, CGFloat)] = []
//    var imageSizes: [[String : Int]] = []
    var expireTime = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    var tags = BehaviorRelay<[String]>(value: [])
    /// uploadAlbum() -> UploadViewController
    let uploadAlbumDone = PublishSubject<Void>()
    
// MARK: - 파이어베이스 업로드
    func uploadAlbum() {
        print("\(type(of: self)) - \(#function)")

        imageTuples.sort { $0.0 < $1.0 }
        let images = imageTuples.map { $0.1 }
        let albumDict = AlbumModel.createDictToUpload(
            expireTime: expireTime,
            images: images,
            tags: tags.value
        )
        
        DataManager.shared.uploadAlbum(albumDict: albumDict, images: images) {
            self.uploadAlbumDone.onNext(())
        }

    }
    
}
