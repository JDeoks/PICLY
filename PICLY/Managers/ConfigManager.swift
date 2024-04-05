//
//  ConfigManager.swift
//  PICLY
//
//  Created by JDeoks on 12/25/23.
//

import Foundation
import Firebase
import FirebaseRemoteConfig
import RxSwift

class ConfigManager {
    
    static let shared = ConfigManager()
    
    let remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    let defaultMaintenanceNotice: String = ""
    let defaultMinimumVersion: String = "1.0"
    
    let fetchRemoteConfigDone = PublishSubject<Void>()

    private init() {
        print("\(type(of: self)) - \(#function)")

        let settings = RemoteConfigSettings()
        // 앱 켤때마다 실행
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    enum RemoteConfigKey: String {
        case rootURL = "rootURL"
        case maintenanceNotice = "maintenanceNotice"
        case minimumVersion = "minimumVersion"
    }
    
    /// Config 서버값 fetch해서 UserDefaults에 저장
    func fetchRemoteConfig() {
        print("\(type(of: self)) - \(#function)")
        
        remoteConfig.fetch { (status, error) in
            if status != .success {
                print("실패 status: \(status)")
                return
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.remoteConfig.activate { _, _ in
                self.setRemoteConfigToLocal {
                    print("fetchRemoteConfigDone")
                    self.fetchRemoteConfigDone.onNext(())
                }
            }
        }
    }
    
    func setRemoteConfigToLocal(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        // rootURL
        if let urlString = self.remoteConfig.configValue(forKey: RemoteConfigKey.rootURL.rawValue).stringValue {
            print("urlString:",urlString)
            if let rootURL = URL(string: urlString) {
                UserDefaults.standard.set(rootURL, forKey: RemoteConfigKey.rootURL.rawValue)
            } else {
                print("URL 변환 실패")
            }
        } else {
            print("forKey: rootURL 없음")
        }
        
        // maintenanceNotice
        if let maintenanceNotice = self.remoteConfig.configValue(forKey: RemoteConfigKey.maintenanceNotice.rawValue).stringValue {
            print("maintenanceNotice:",maintenanceNotice)
            UserDefaults.standard.set(maintenanceNotice, forKey: RemoteConfigKey.maintenanceNotice.rawValue)
        } else {
            print("forKey: maintenanceNotice 없음")
        }

        // minimumVersion
        if let minimumVersion = self.remoteConfig.configValue(forKey: RemoteConfigKey.minimumVersion.rawValue).stringValue {
            print("minimumVersion:",minimumVersion)
            UserDefaults.standard.set(minimumVersion, forKey: RemoteConfigKey.minimumVersion.rawValue)
        } else {
            print("forKey: minimumVersion 없음")
        }
        completion()
    }
    
    func isMinimumVersionSatisfied() -> Bool {
        print("\(type(of: self)) - \(#function)")

        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
        let minimumVersion = getMinimumVersionFromLocal()
        print("currentAppVersion: ", currentAppVersion, "minimumVersion: ", minimumVersion)
        print("유효한 버전 확인:", currentAppVersion.compare(minimumVersion, options: .numeric) != .orderedAscending)
        return currentAppVersion.compare(minimumVersion, options: .numeric) != .orderedAscending
    }
    
    func getRootURLFromLocal() -> URL {
        guard let rootURL = UserDefaults.standard.url(forKey: RemoteConfigKey.rootURL.rawValue) else {
            print("forKey: rootURL 없음. 기본 값 사용")
            return PICLYConstants.defaultRootURL
        }
        return rootURL
    }
    
    func getIsCheckingFromLocal() -> String {
        print("\(type(of: self)) - \(#function)")

        guard let maintenanceNotice = UserDefaults.standard.string(forKey: RemoteConfigKey.maintenanceNotice.rawValue) else {
            print("forKey: maintenanceNotice 없음. 기본 값 사용")
            return defaultMaintenanceNotice
        }
        return maintenanceNotice
    }
    
    func getMinimumVersionFromLocal() -> String {
        print("\(type(of: self)) - \(#function)")

        guard let minimumVersion = UserDefaults.standard.string(forKey: RemoteConfigKey.minimumVersion.rawValue) else {
            print("forKey: minimumVersion 없음. 기본 값 사용")
            return defaultMinimumVersion
        }
        return minimumVersion
    }
    
}
