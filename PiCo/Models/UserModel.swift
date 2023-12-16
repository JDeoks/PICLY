//
//  UserModel.swift
//  PiCo
//
//  Created by JDeoks on 12/14/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAnalytics
import SwiftDate

class UserModel {
    
    /// 고유 DocID
    var userID: String
    var email: String
    var creationTime: Date
    /// 로그인 제공자
    var authProvider: AuthProvider
    var albumIDs: [String]
    
    init(document: DocumentSnapshot) {
        self.userID = document.documentID
        self.email = document.data()?["email"] as? String ?? "email 없음"
        self.creationTime = (document.data()?["creationTime"] as? Timestamp)?.dateValue() ?? Date()
        self.authProvider = AuthProvider(rawValue: document.data()?["authProvider"] as? String ?? "email") ?? .email
        self.albumIDs = document.data()?["albumIDs"] as? [String] ?? []
    }
    
}
