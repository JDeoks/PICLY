//
//  UserModel.swift
//  PICLY
//
//  Created by JDeoks on 12/14/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import SwiftDate

class UserModel {
    
    /// 고유 DocID
    var userID: String
    var email: String
    var creationTime: Date
    var authProvider: AuthProvider
    
    init(document: DocumentSnapshot) {
        let data = document.data() ?? [:]

        self.userID = document.documentID
        self.email = data[UserField.email.rawValue] as? String ?? "email 없음"
        self.creationTime = (data[UserField.creationTime.rawValue] as? Timestamp)?.dateValue() ?? Date()
        print("\(UserField.authProvider.rawValue)")
        self.authProvider = AuthProvider(rawValue: data[UserField.authProvider.rawValue] as? String ?? "Email") ?? .email
        print(authProvider)
    }
    
    init(user: User) {
        print("\(type(of: self)) - \(#function)")

        self.userID = user.uid
        self.email = user.email ?? ""
        self.creationTime = user.metadata.creationDate ?? Date()
        if user.providerData.isEmpty {
            self.authProvider = .email
        } else {
            self.authProvider = AuthProvider(string: user.providerData[0].providerID )!
        }
    }
    
    func getCreationTimeString(format: String = "yyyy.MM.dd" ) -> String {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        return DateInRegion(self.creationTime, region: region).toFormat(format)
    }
    
    static func createDictToUpload(provider: AuthProvider, user: User) -> [String: Any]{
        let dictionary: [String: Any] = [
            UserField.creationTime.rawValue: Timestamp(date: Date()),
            UserField.authProvider.rawValue: provider.rawValue,
            UserField.email.rawValue: user.email ?? "없음"
        ]
        return dictionary
    }
    
}
