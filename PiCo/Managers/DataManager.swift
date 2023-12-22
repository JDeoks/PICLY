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
    
    let usersCollection = Firestore.firestore().collection("Users")
    
    
    
}
