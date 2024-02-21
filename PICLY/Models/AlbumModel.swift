//
//  AlbumModel.swift
//  PICLY
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
    var thumbnailURL: URL
    var imageURLs: [URL]
    var imageCount: Int
    var imageSizes: [[String: Int]]
    var tags: [String]
    var viewCount: Int
    var isSkeleton: Bool
    let defaultImageURLStr = "https://firebasestorage.googleapis.com/v0/b/pico-a81e4.appspot.com/o/defaultImage.jpg?alt=media&token=3d4ec053-7345-4128-b853-f8c8bef72113"
    
    init(document: DocumentSnapshot) {
        let defaultImageURL = URL(string: defaultImageURLStr)!
        let data = document.data() ?? [:]
        
        self.albumID = document.documentID
        self.ownerID = data[AlbumField.ownerID.rawValue] as? String ?? ""
        self.creationTime = (data[AlbumField.creationTime.rawValue] as? Timestamp)?.dateValue() ?? Date()
        self.expireTime = (data[AlbumField.expireTime.rawValue] as? Timestamp)?.dateValue() ?? Date()

        let thumbnailURLString = data[AlbumField.thumbnailURL.rawValue] as? String
        self.thumbnailURL = URL(string: thumbnailURLString ?? defaultImageURLStr) ?? defaultImageURL

        let imageURLsStrArray = data[AlbumField.imageURLs.rawValue] as? [String] ?? [defaultImageURLStr]
        self.imageURLs = imageURLsStrArray.compactMap { URL(string: $0) }

        self.imageCount = data[AlbumField.imageCount.rawValue] as? Int ?? 1
        self.imageSizes = data[AlbumField.imageSizes.rawValue] as? [[String: Int]] ?? [[AlbumField.width.rawValue: 1000], [AlbumField.height.rawValue: 1000]]
        self.tags = data[AlbumField.tags.rawValue] as? [String] ?? []
        self.viewCount = data[AlbumField.viewCount.rawValue] as? Int ?? 0
        self.isSkeleton = false
    }
    
    /// 스켈레톤뷰 생성
    init() {
        self.albumID = ""
        self.ownerID = ""
        self.creationTime = Date()
        self.expireTime = Date()
        let defaultImageURL = URL(string: defaultImageURLStr)!
        self.thumbnailURL = defaultImageURL
        self.imageURLs = [URL(string: "https://jdeoks.notion.site/PICLY-97084d79dfe649918ba5179298f158f9?pvs=4")!]
        self.imageCount = 0
        self.imageSizes = [["": 0]]
        self.tags = [""]
        self.viewCount = 0
        self.isSkeleton = true
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
    
    static func createDictToUpload(expireTime: Date, images: [UIImage], tags: [String]) -> [String: Any] {
        let imageCount = images.count
        let imageSizes = images.map { $0.getSizeDict() }
        let dictionary: [String: Any] = [
            AlbumField.ownerID.rawValue: Auth.auth().currentUser!.uid,
            AlbumField.creationTime.rawValue: Timestamp(date: Date()),
            AlbumField.expireTime.rawValue: Timestamp(date: expireTime),
            AlbumField.imageCount.rawValue: imageCount,
            AlbumField.imageSizes.rawValue: imageSizes,
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
    
    /// height / width
    func getImageAspectRatio(index: Int) -> Float {
        if imageSizes.indices.contains(index) {
            let width = Float(imageSizes[index][AlbumField.width.rawValue] ?? 100)
            let height = Float(imageSizes[index][AlbumField.height.rawValue] ?? 100)
            return height / width
        }
        return 1.0
    }
    
}
