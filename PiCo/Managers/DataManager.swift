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

class DataManager {
    
    static let shared = DataManager()
    private init() { }
    
    let albumsCollection = Firestore.firestore().collection("Albums")
    let usersCollection = Firestore.firestore().collection("Users")
    var albums: [AlbumModel] = []
    
    /// fetchAlbums() -> MyAlbumsViewController
    let fetchAlbumsDone = PublishSubject<Void>()
    
    func fetchAlbums() {
        print("\(type(of: self)) - \(#function)")

        albums.removeAll()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("currentUser 없음 ")
            return
        }
        albumsCollection
            .whereField(AlbumField.ownerID.rawValue, isEqualTo: userID)
            .order(by: AlbumField.creationTime.rawValue, descending: true) // 최신순 정렬
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let album = AlbumModel(document: document)
                        self.albums.append(album)
                    }
                    self.fetchAlbumsDone.onNext(())
                }
            }
    }
    
}
