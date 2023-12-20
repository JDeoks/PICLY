//
//  UserField.swift
//  PiCo
//
//  Created by JDeoks on 12/21/23.
//

import Foundation

enum UserField: String {
    
    case email = "email"
    case google = "google"
    case apple = "apple"

    init?(providerString: String) {
        self.init(rawValue: providerString.lowercased())
    }
    
    /// 첫글자 대문자로 바꿔서 return ex) "Email", "Google", "Apple"
    var description: String {
        let originalString = self.rawValue
        let capitalizedString = originalString.prefix(1).uppercased() + originalString.dropFirst()
        return capitalizedString
    }
    
}
