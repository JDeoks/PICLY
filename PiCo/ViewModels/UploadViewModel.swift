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
    /// 선택한 사진 배열
    var images: [UIImage] = []
    // TODO: tags 업데이트
    var expireTime = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    
    var tags = BehaviorRelay<[String]>(value: [])
    /// uploadAlbum() -> UploadViewController
    let uploadAlbumDone = PublishSubject<Void>()
    
// MARK: - 파이어베이스 업로드
    func uploadAlbum() {
        print("\(type(of: self)) - \(#function)")
        
        uploadAlbumDocToFireStore() { albumDocID in
            self.uploadImagesToStorage(albumDocID: albumDocID) {
                print("\(#function) 성공")
                self.uploadAlbumDone.onNext(())
            }
        }
    }
    
    /// AlbumModel을 FireStore에 추가
    func uploadAlbumDocToFireStore( completion: @escaping (String) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let documentData = AlbumModel.createDictToUpload(expireTime: expireTime, imageCount: images.count, tags: tags.value)
        var ref: DocumentReference? = nil
        ref = albumCollection.addDocument(data: documentData) { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
            } else {
                print("\(#function) 성공: \(ref!.documentID)")
                completion(ref!.documentID)
            }
        }
    }
    
    /// 이미지를 Storage에 업로드
    func uploadImagesToStorage(albumDocID: String, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        // asdfsaf/0
        let albumImagesRef = Storage.storage().reference().child(albumDocID)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadGroup = DispatchGroup()
        print("images.count:", images.count)
        for imageIdx in 0..<images.count {
            let uploadRef = albumImagesRef.child("\(imageIdx).jpeg")
            if let imageData = images[imageIdx].jpegData(compressionQuality: 0.8) {
                uploadGroup.enter()
                uploadRef.putData(imageData, metadata: metadata) { metadata, error in
                    uploadGroup.leave()
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            completion()
        }
    }
}
