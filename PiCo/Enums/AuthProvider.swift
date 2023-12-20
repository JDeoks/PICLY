//
//  AuthProvider.swift
//  PiCo
//
//  Created by JDeoks on 12/15/23.
//

import Foundation

enum AuthProvider: String {
    
    case email = "Email"
    case google = "Google"
    case apple = "Apple"

    init?(string: String) {
        self.init(rawValue: string)
    }
    
}
