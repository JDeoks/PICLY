//
//  PhotoModel.swift
//  PiCo
//
//  Created by 서정덕 on 11/20/23.
//

import Foundation
//import SwiftDate

class PhotoModel {
    
    var photoID: String
    var creationTime: Date
    var expireTime: Date
    var imageURL: URL
    var shareURL: URL
    var tag: String
    var views: Int
    
    init(photoID: String?, creationTime: Date?, expireTime: Date?, shareURL: URL?, imageURL: URL?, tag: String?, views: Int?) {
        self.photoID = photoID ?? ""
        self.creationTime = creationTime ?? Date()
        self.expireTime = expireTime ?? Date()
        self.shareURL = shareURL ?? URL(fileURLWithPath: "nil")
        self.imageURL = imageURL ?? URL(fileURLWithPath: "nil")
        self.tag = tag ?? ""
        self.views = views ?? 0
    }
    
//    func getCreationTimeStr() -> String {
//        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
//        return DateInRegion(self.creationTime, region: region).toFormat("yyyy-MM-dd HH:mm")
//    }
//    
//    func getExpireTimeStr() -> String {
//        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
//        return DateInRegion(self.expireTime, region: region).toFormat("yyyy-MM-dd HH:mm")
//    }
//    
}
