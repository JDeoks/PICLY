//
//  UserField.swift
//  PiCo
//
//  Created by JDeoks on 12/21/23.
//

import Foundation

enum UserField: String {
    
    case userID = "userID"
    case socialID = "socialID"
    case creationTime = "creationTime"
    case authProvider = "authProvider"
    case albumIDs = "albumIDs"

    init?(string: String) {
        self.init(rawValue: string)
    }
    
}
