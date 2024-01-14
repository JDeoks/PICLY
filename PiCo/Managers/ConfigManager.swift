//
//  ConfigManager.swift
//  PiCo
//
//  Created by JDeoks on 12/25/23.
//

import Foundation
import Firebase
import FirebaseRemoteConfig
import RxSwift

class ConfigManager {
    
    static let shared = ConfigManager()
    
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
        case isChecking = "isServerMaintenance"
        case minimumVersion = "minimumVersion"
    }
    
    let remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    let defaultRootURL: URL = URL(string: "https://picoweb.vercel.app/")!
    let defaultIsChecking: Bool = false
    let defaultMinimumVersion: String = "1.0"
    
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
        
        // isChecking
        let isChecking = self.remoteConfig.configValue(forKey: RemoteConfigKey.isChecking.rawValue).boolValue
        print("isChecking:", isChecking)
        UserDefaults.standard.set(isChecking, forKey: RemoteConfigKey.isChecking.rawValue)
        
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
        print(currentAppVersion.compare(minimumVersion, options: .numeric) != .orderedAscending)
        return currentAppVersion.compare(minimumVersion, options: .numeric) != .orderedAscending
    }
    
    func getRootURLFromLocal() -> URL {
        print("\(type(of: self)) - \(#function)")

        guard let rootURL = UserDefaults.standard.url(forKey: RemoteConfigKey.rootURL.rawValue) else {
            print("forKey: rootURL 없음. 기본 값 사용")
            return defaultRootURL
        }
        return rootURL
    }
    
    func getIsMaintainedFromLocal() -> Bool {
        print("\(type(of: self)) - \(#function)")

        if UserDefaults.standard.object(forKey: RemoteConfigKey.isChecking.rawValue) != nil {
            // 해당 키가 존재하는 경우
            return UserDefaults.standard.bool(forKey: RemoteConfigKey.isChecking.rawValue)
        } else {
            // 해당 키가 존재하지 않는 경우
            print("forKey: isChecking 없음. 기본 값 사용")
            return defaultIsChecking
        }
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
