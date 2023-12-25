//
//  ConfigManager.swift
//  PiCo
//
//  Created by JDeoks on 12/25/23.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

class ConfigManager {
    
    static let shared = ConfigManager()
    private init() {}
    
    var remoteConfig: RemoteConfig?
    let defaultRootURL = URL(string: "http.app/")!
    
//    func setRemoteConfig() {
//        print("\(type(of: self)) - \(#function)")
//
//        remoteConfig = RemoteConfig.remoteConfig()
//        let settings = RemoteConfigSettings()
//        // 앱 켤때마다 실행
//        settings.minimumFetchInterval = 0
//        remoteConfig?.configSettings = settings
//        // 기본 설정
//        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
//        fetchRemoteConfig()
//    }
    
    func fetchRemoteConfig() {
        print("\(type(of: self)) - \(#function)")
        
        // TODO: nil일때만 기본값 적용
        print(defaultRootURL)
        UserDefaults.standard.set(defaultRootURL, forKey: "rootURL")
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetch { (status, error) in
            if status != .success {
                print("실패 status: \(status)")
                return
            }
            guard let urlString = remoteConfig.configValue(forKey: "rootURL").stringValue else {
                print("forKey: rootURL 없음")
                return
            }
            guard let url = URL(string: urlString) else {
                print("URL 변환 실패")
                return
            }
            UserDefaults.standard.set(url, forKey: "rootURL")
            print("\(type(of: self)) - \(#function) \(url)")
        }
    }
    
}
