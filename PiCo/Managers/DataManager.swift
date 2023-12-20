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
    
    let albumCollection = Firestore.firestore().collection("Albums")
    
    // 내 앨범리스트 에 새 앨범 추가
    func appendAlbumIDToUserDoc(albumID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let userDocRef = albumCollection.document(userID)

        // 배열 필드 업데이트
        userDocRef.updateData([
            "albumIDs": FieldValue.arrayUnion(["albumID"])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("appendAlbumIDToUserDoc 성공")
                LoginManager.shared.getUserModelFromServer()
            }
        }
    }
    
}
