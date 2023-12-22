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

class UserModel: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true

    /// 고유 DocID
    var userID: String
    var socialID: String
    var creationTime: Date
    var authProvider: AuthProvider
    
    init(document: DocumentSnapshot) {
        print("\(type(of: self)) - \(#function)")
        self.userID = document.documentID
        self.socialID = document.data()?[UserField.socialID.rawValue] as? String ?? "email 없음"
        self.creationTime = (document.data()?[UserField.creationTime.rawValue] as? Timestamp)?.dateValue() ?? Date()
        print("\(UserField.authProvider.rawValue)")
        self.authProvider = AuthProvider(rawValue: document.data()?[UserField.authProvider.rawValue] as? String ?? "socialID") ?? .email
        print(authProvider)
    }

    required init?(coder: NSCoder) {
        guard let userID = coder.decodeObject(forKey: "userID") as? String,
              let email = coder.decodeObject(forKey: "socialID") as? String,
              let creationTime = coder.decodeObject(forKey: "creationTime") as? Date,
              let providerString = coder.decodeObject(forKey: "authProvider") as? String,
              let authProvider = AuthProvider(string: providerString)else {
            return nil
        }

        self.userID = userID
        self.socialID = email
        self.creationTime = creationTime
        self.authProvider = authProvider
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.userID, forKey: "userID")
        coder.encode(self.socialID, forKey: "socialID")
        coder.encode(self.creationTime, forKey: "creationTime")
        coder.encode(self.authProvider.rawValue, forKey: "authProvider")
    }
    
    func getCreationTimeString(format: String = "yyyy.MM.dd" ) -> String {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        return DateInRegion(self.creationTime, region: region).toFormat(format)
    }
    
}
