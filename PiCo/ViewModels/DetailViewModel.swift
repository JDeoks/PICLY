//
//  DetailViewModel.swift
//  PiCo
//
//  Created by JDeoks on 1/3/24.
//

import Foundation
import RxSwift
import FirebaseFirestore
import FirebaseStorage

class DetailViewModel {
    
    let albumsCollection = Firestore.firestore().collection("Albums")
    var album: AlbumModel!
    var albumURL: URL?
    
    let deleteAlbumDone = PublishSubject<Void>()
    let deleteFailed = PublishSubject<Void>()
    
    func deleteAlbum() {
        print("\(type(of: self)) - \(#function)")

        deleteAlbumDoc {
            self.deleteAlbumImage {
                self.deleteAlbumDone.onNext(())
            }
        }
    }
    
    func deleteAlbumDoc(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        albumsCollection.document(album.albumID).delete() { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
                self.deleteFailed.onNext(())
            } else {
                print("Document successfully removed!")
                completion()
            }
        }
    }
    
    func deleteAlbumImage(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let albumImagesRef = Storage.storage().reference().child(album.albumID)
        albumImagesRef.listAll { (result, error) in
            if let error = error {
                print("Error in listing files: \(error)")
                self.deleteFailed.onNext(())
                return
            }
            guard let result = result else {
                print("\(#function) result 없음")
                self.deleteFailed.onNext(())
                return
            }
            let deleteAlbumGroup = DispatchGroup()
            
            for item in result.items {
                deleteAlbumGroup.enter()
                item.delete { error in
                    if let error = error {
                        print("Error deleting file: \(error)")
                    } else {
                        print("File deleted successfully")
                    }
                    deleteAlbumGroup.leave()
                }
            }
            
            deleteAlbumGroup.notify(queue: .main) {
                completion()
            }
        }
    }
    
}
