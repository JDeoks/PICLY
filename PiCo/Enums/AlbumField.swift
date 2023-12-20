//
//  AlbumField.swift
//  PiCo
//
//  Created by JDeoks on 12/21/23.
//

import Foundation

enum AlbumField: String {
        
    case albumID = "albumID"
    case creationTime = "creationTime"
    case expireTime = "expireTime"
    case imageCount = "imageCount"
    case albumURL = "albumURL"
    case tag = "tag"
    case viewCount = "viewCount"

    init?(string: String) {
        self.init(rawValue: string)
    }
    
}
