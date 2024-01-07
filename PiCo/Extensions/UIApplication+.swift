//
//  UIApplication+.swift
//  PiCo
//
//  Created by JDeoks on 1/7/24.
//

import Foundation
import UIKit

extension UIApplication {
    
    func getWindow() -> UIWindow {
        let scenes: Set<UIScene> = UIApplication.shared.connectedScenes
        let windowScene: UIWindowScene? = scenes.first as? UIWindowScene
        let window: UIWindow = windowScene!.windows.first!
        return window
    }
    
}
