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

/// 파이어베이스 통신 매니저
class DataManager {
    
    static let shared = DataManager()
    private init() { }
    
    let albumsCollection = Firestore.firestore().collection("Albums")
    let usersCollection = Firestore.firestore().collection("Users")
    var myAlbums: [AlbumModel] = []
    
    ///updateMyAlbums() -> MyAlbumsViewController
    let updateMyAlbumsDone = PublishSubject<Void>()
    
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
    
}
