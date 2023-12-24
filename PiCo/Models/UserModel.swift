//
//  UserModel.swift
//  PiCo
//
//  Created by JDeoks on 12/14/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import SwiftDate

class UserModel: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true

    /// 고유 DocID
    var userID: String
    /// email
    var email: String
    var creationTime: Date
    var authProvider: AuthProvider
    
    init(document: DocumentSnapshot) {
        print("\(type(of: self)) - \(#function)")
        
        self.userID = document.documentID
        self.email = document.data()?[UserField.email.rawValue] as? String ?? "email 없음"
        self.creationTime = (document.data()?[UserField.creationTime.rawValue] as? Timestamp)?.dateValue() ?? Date()
        print("\(UserField.authProvider.rawValue)")
        self.authProvider = AuthProvider(rawValue: document.data()?[UserField.authProvider.rawValue] as? String ?? "email") ?? .email
        print(authProvider)
    }

    required init?(coder: NSCoder) {
        guard let userID = coder.decodeObject(forKey: UserField.userID.rawValue) as? String,
              let email = coder.decodeObject(forKey: UserField.email.rawValue) as? String,
                                                let creationTime = coder.decodeObject(forKey: UserField.creationTime.rawValue) as? Date,
              let providerString = coder.decodeObject(forKey: UserField.authProvider.rawValue) as? String,
              let authProvider = AuthProvider(string: providerString)else {
            return nil
        }
        self.userID = userID
        self.email = email
        self.creationTime = creationTime
        self.authProvider = authProvider
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.userID, forKey: UserField.userID.rawValue)
        coder.encode(self.email, forKey: UserField.email.rawValue)
        coder.encode(self.creationTime, forKey: UserField.creationTime.rawValue)
        coder.encode(self.authProvider.rawValue, forKey: UserField.authProvider.rawValue)
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
