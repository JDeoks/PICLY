//
//  DataManager.swift
//  PiCo
//
//  Created by JDeoks on 12/21/23.
//

import Foundation
import RxSwift
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

/// 파이어베이스 통신 매니저
class DataManager {
    
    static let shared = DataManager()
    private init() { }
    
    let albumsCollection = Firestore.firestore().collection("Albums")
    let usersCollection = Firestore.firestore().collection("Users")
    var myAlbums: [AlbumModel] = [AlbumModel(), AlbumModel(), AlbumModel()]
    
    ///updateMyAlbums() -> MyAlbumsViewController
    let updateMyAlbumsDone = PublishSubject<Void>()
    
    // MARK: - 파이어베이스 fetch
    func fetchMyAlbums() {
        print("\(type(of: self)) - \(#function)")

        guard let userID = Auth.auth().currentUser?.uid else {
            print("\(#function): currentUser 없음 ")
            return
        }
        /// 내 앨범 최신순으로
        let query = albumsCollection
            .whereField(AlbumField.ownerID.rawValue, isEqualTo: userID)
            .order(by: AlbumField.creationTime.rawValue, descending: true)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("querySnapshot: nil")
                return
            }
            self.updateMyAlbums(querySnapshot: querySnapshot)
        }
    }
    
    private func updateMyAlbums(querySnapshot: QuerySnapshot) {
        myAlbums.removeAll()
        for document in querySnapshot.documents {
            let album = AlbumModel(document: document)
            myAlbums.append(album)
        }
        self.updateMyAlbumsDone.onNext(())
    }
    
    // MARK: - 파이어베이스 업로드
    func uploadAlbum(albumDict: [String : Any], images: [UIImage], complition: @escaping (_ albumURL: URL) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let rootURL: URL = ConfigManager.shared.getRootURLFromLocal()
        uploadAlbumDocToFireStore(albumDict: albumDict, images: images) { albumDocID in
            self.uploadImagesToStorage(albumDocID: albumDocID, images: images) { imageURLTuples in
                self.updateImageURLsToAlbumDoc(albumDocID: albumDocID, imageURLTuples: imageURLTuples) {
                    let albumURL = rootURL.appendingPathComponent("Album").appendingPathComponent(albumDocID)
                    complition(albumURL)
                }
            }
        }
    }
        
    /// AlbumModel을 FireStore에 추가
    private func uploadAlbumDocToFireStore(albumDict: [String : Any], images: [UIImage], completion: @escaping (String) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        var ref: DocumentReference? = nil
        ref = albumsCollection.addDocument(data: albumDict) { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
            } else {
                print("\(#function) 성공: \(ref!.documentID)")
                let rootURL: URL = ConfigManager.shared.getRootURLFromLocal()
                completion(ref!.documentID)
            }
        }
    }
    
    /// 이미지를 Storage에 업로드
    private func uploadImagesToStorage(albumDocID: String, images: [UIImage], completion: @escaping (_ imageURLTuples: [(Int, URL)]) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        var imageURLTuples: [(Int, URL)] = []
        // 스토리지 ref = albumDocID/imageIndex
        let albumImagesRef = Storage.storage().reference().child(albumDocID)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadGroup = DispatchGroup()
        // 썸네일 업로드
        if images.isEmpty {
            return
        }
        
        /// idx 0에 썸네일 이미지 업로드
        let thumbnailRef: StorageReference = albumImagesRef.child("thumbnail.jpeg")
        uploadGroup.enter()
        uploadSingleImageToStorage(uploadRef: thumbnailRef, image: images[0], compressionQuality: 0.1) { url in
            if let url = url {
                imageURLTuples.append((0, url))
            }
            uploadGroup.leave()
        }

        // idx 1부터 앨범 전체 이미지 업로드
        for idx in 0..<images.count {
            uploadGroup.enter()
            let uploadRef = albumImagesRef.child("\(idx).jpeg")
            uploadSingleImageToStorage(uploadRef: uploadRef, image: images[idx], compressionQuality: 0.5) { url in
                if let url = url {
                    // idx 0 은 썸네일
                    imageURLTuples.append((idx + 1, url))
                }
                uploadGroup.leave()
            }
        }
        
        uploadGroup.notify(queue: .main) {
            imageURLTuples.sort { $0.0 < $1.0 }
            completion(imageURLTuples)
        }
    }
    
    /// 단일 이미지 업로드
    private func uploadSingleImageToStorage(uploadRef: StorageReference, image: UIImage, compressionQuality: CGFloat, completion: @escaping (_ url: URL?) -> Void) {
        print("\(type(of: self)) - \(#function)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let thumbnailImage = image.jpegData(compressionQuality: 0.1) {
            uploadRef.putData(thumbnailImage, metadata: metadata) { metadata, error in
                uploadRef.downloadURL { url, error in
                    completion(url)
                }
            }
        }
    }
    
    private func updateImageURLsToAlbumDoc(albumDocID: String, imageURLTuples: [(Int, URL)], completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        let albumDocRef = albumsCollection.document(albumDocID)
        // imageURLs 배열을 String 배열로 변환
        var urlStrs = imageURLTuples.map { $0.1.absoluteString }
        let thumbnailUrlStr: String = urlStrs.removeFirst()
        let mainImageUrlStrs = urlStrs
        print("mainImageUrlStrs", mainImageUrlStrs, "thumbnailUrlStr", thumbnailUrlStr)
        let dict: [String : Any] = [AlbumField.imageURLs.rawValue: mainImageUrlStrs, AlbumField.thumbnailURL.rawValue: thumbnailUrlStr]
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
