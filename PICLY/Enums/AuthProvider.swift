//
//  AuthProvider.swift
//  PICLY
//
//  Created by JDeoks on 12/15/23.
//

import Foundation

enum AuthProvider: String {
    
    case email = "Email"
    case google = "Google"
    case apple = "Apple"

    init?(string: String) {
        switch string {
        case "password":
            self = .email
        case "google.com":
            self = .google
        case "apple.com":
            self = .apple
        default:
            return nil
        }
    }
    
}

