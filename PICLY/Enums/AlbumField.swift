//
//  AlbumField.swift
//  PICLY
//
//  Created by JDeoks on 12/21/23.
//

import Foundation

enum AlbumField: String {
        
    case albumID = "albumID"
    case ownerID = "ownerID"
    case creationTime = "creationTime"
    case expireTime = "expireTime"
    case thumbnailURL = "thumbnailURL"
    case imageURLs = "imageURLs"
    case imageCount = "imageCount"
    case imageSizes = "imageSizes"
    case tags = "tags"
    case viewCount = "viewCount"
    // imageSizes key
    case height = "height"
    case width = "width"

    init?(string: String) {
        self.init(rawValue: string)
    }
    
}
