//
//  AlbumModel.swift
//  PiCo
//
//  Created by 서정덕 on 11/20/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAnalytics
import SwiftDate

class AlbumModel {
    
    var albumID: String
    var creationTime: Date
    var expireTime: Date
    var imageCount: Int
    var shareURL: URL
    var tag: String
    var viewCount: Int
    
    init(document: DocumentSnapshot) {
        self.albumID = document.documentID
        self.creationTime = (document.data()?["creationTime"] as? Timestamp)?.dateValue() ?? Date()
        self.expireTime = (document.data()?["expireTime"] as? Timestamp)?.dateValue() ?? Date()
        self.imageCount = document.data()?["imageCount"] as! Int
        //TODO: shareURL 제대로
        self.shareURL = URL(fileURLWithPath: "nil")
        self.tag = document.data()?["tag"] as! String
        self.viewCount = document.data()?["viewCount"] as! Int
    }
    
    init(photoID: String?, creationTime: Date?, expireTime: Date?, shareURL: URL?, imageCount: Int, tag: String?, viewCount: Int?) {
        self.albumID = photoID ?? ""
        self.creationTime = creationTime ?? Date()
        self.expireTime = expireTime ?? Date()
        self.shareURL = shareURL ?? URL(fileURLWithPath: "nil")
        self.imageCount = imageCount
        self.tag = tag ?? ""
        self.viewCount = viewCount ?? 0
    }
    
    func getCreationTimeStr() -> String {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        return DateInRegion(self.creationTime, region: region).toFormat("yyyy-MM-dd HH:mm")
    }
    
    func getExpireTimeStr() -> String {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        return DateInRegion(self.expireTime, region: region).toFormat("yyyy-MM-dd HH:mm")
    }
    
    func getDDay() -> Int {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        let now = DateInRegion(region: region)
        let expirationDate = DateInRegion(expireTime, region: region)
        let days = now.getInterval(toDate: expirationDate, component: .day)
        return Int(days)
    }
    
}
