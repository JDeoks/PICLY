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
    var ownerID: String
    var creationTime: Date
    var expireTime: Date
    var thumbnailURL: URL?
    var imageURLs: [URL]
    var imageCount: Int
    var tags: [String]
    var viewCount: Int
    
    init(document: DocumentSnapshot) {
        self.albumID = document.documentID
        self.ownerID = document.data()?[AlbumField.ownerID.rawValue] as! String
        self.creationTime = (document.data()?[AlbumField.creationTime.rawValue] as! Timestamp).dateValue()
        self.expireTime = (document.data()?[AlbumField.expireTime.rawValue] as! Timestamp).dateValue()
        let thumbnailURLString = document.data()?[AlbumField.thumbnailURL.rawValue] as! String
        self.thumbnailURL = URL(string: thumbnailURLString)!
        let imageURLsStrArray = document.data()?[AlbumField.imageURLs.rawValue] as! [String]
        self.imageURLs = imageURLsStrArray.compactMap { URL(string: $0) }
        self.imageCount = document.data()?[AlbumField.imageCount.rawValue] as! Int
        self.tags = document.data()?[AlbumField.tags.rawValue] as! [String]
        self.viewCount = document.data()?[AlbumField.viewCount.rawValue] as! Int
    }
    
    init(albumID: String, ownerID: String, creationTime: Date, expireTime: Date, imageCount: Int, tags: [String], viewCount: Int) {
        self.albumID = albumID
        self.ownerID = ownerID
        self.creationTime = creationTime
        self.expireTime = expireTime
        self.thumbnailURL = nil
        self.imageURLs = []
        self.imageCount = imageCount
        self.tags = tags
        self.viewCount = viewCount
    }
        
    func getCreationTimeStr() -> String {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        return DateInRegion(self.creationTime, region: region).toFormat("yyyy.MM.dd HH:mm")
    }
    
    func getExpireTimeStr() -> String {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        return DateInRegion(self.expireTime, region: region).toFormat("yyyy.MM.dd HH:mm")
    }
    
    func getDDay() -> Int {
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        let now = DateInRegion(region: region)
        let expirationDate = DateInRegion(expireTime, region: region)
        let days = now.getInterval(toDate: expirationDate, component: .day)
        
        return Int(days)
    }
    
    static func createDictToUpload(expireTime: Date, imageCount: Int, tags: [String]) -> [String: Any] {
        let dictionary: [String: Any] = [
            AlbumField.ownerID.rawValue: Auth.auth().currentUser!.uid,
            AlbumField.creationTime.rawValue: Timestamp(date: Date()),
            AlbumField.expireTime.rawValue: Timestamp(date: expireTime),
            AlbumField.imageCount.rawValue: imageCount,
            AlbumField.tags.rawValue: tags,
            AlbumField.viewCount.rawValue: 0
        ]
        return dictionary
    }
    
    func getTimeRemainingStr() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: now, to: expireTime)
        
        if expireTime < Date() {
            return "만료"
        }
        guard let totalMinutes = components.minute else {
            return "만료"
        }
        
        let days = totalMinutes / (24 * 60)
        let hours = (totalMinutes % (24 * 60)) / 60
        let minutes = (totalMinutes % (24 * 60)) % 60

        return "\(days)일 \(hours)시간 \(minutes)분 후 만료"
    }
    
}
