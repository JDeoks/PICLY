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
    var thumbnailURL: URL?
    /// 앨범에 추가할 이미지 접근 url
    var imageURLs: [URL] = []
    var imageSizes: [[String : Int]] = []
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
                self.updateImageURLsToAlbumDoc(albumDocID: albumDocID) {
                    self.uploadAlbumDone.onNext(())
                }
            }
        }
    }
    
    /// AlbumModel을 FireStore에 추가
    func uploadAlbumDocToFireStore( completion: @escaping (String) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let documentData = AlbumModel.createDictToUpload(
            expireTime: expireTime,
            imageCount: images.count,
            tags: tags.value,
            imageSizes: imageSizes
        )
        var ref: DocumentReference? = nil
        ref = albumCollection.addDocument(data: documentData) { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
            } else {
                print("\(#function) 성공: \(ref!.documentID)")
                let rootURL: URL = ConfigManager.shared.getRootURL()
                self.albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(ref!.documentID)
                completion(ref!.documentID)
            }
        }
    }
    
    /// 이미지를 Storage에 업로드
    func uploadImagesToStorage(albumDocID: String, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        // 스토리지 ref = albumDocID/imageIndex
        let albumImagesRef = Storage.storage().reference().child(albumDocID)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadGroup = DispatchGroup()
        print("images.count:", images.count)
        
        if images.isEmpty == false {
            let uploadRef = albumImagesRef.child("thumbnail.jpeg")
            if let thumbnailImage = images[0].jpegData(compressionQuality: 0.1) {
                uploadGroup.enter()
                uploadRef.putData(thumbnailImage, metadata: metadata) { metadata, error in
                    uploadRef.downloadURL { url, error in
                        guard let url = url else {
                            return
                        }
                        self.thumbnailURL = url
                        uploadGroup.leave()
                    }
                }
            }
        }
        for imageIdx in 0..<images.count {
            let uploadRef = albumImagesRef.child("\(imageIdx).jpeg")
            if let imageData = images[imageIdx].jpegData(compressionQuality: 0.5) {
                uploadGroup.enter()
                uploadRef.putData(imageData, metadata: metadata) { metadata, error in
                    uploadRef.downloadURL { url, error in
                        guard let url = url else {
                            return
                        }
                        self.imageURLs.append(url)
                        uploadGroup.leave()
                    }
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func updateImageURLsToAlbumDoc(albumDocID: String, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        let albumDocRef = albumCollection.document(albumDocID)
        // imageURLs 배열을 String 배열로 변환
        let urlsStringArray = imageURLs.map { $0.absoluteString }
        let thumbnailStr: String = thumbnailURL?.absoluteString ?? "nil"
        let dict: [String : Any] = [AlbumField.imageURLs.rawValue: urlsStringArray, AlbumField.thumbnailURL.rawValue: thumbnailStr] 
        albumDocRef.updateData(dict) { error in
            if let error = error {
                print("Doc 업데이트 실패: \(error)")
            } else {
                print("Doc 업데이트 성공")
                completion()
            }
        }
    }
    
}
