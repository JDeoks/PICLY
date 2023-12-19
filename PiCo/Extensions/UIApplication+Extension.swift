//
//  UIApplication+Extension.swift
//  PiCo
//
//  Created by JDeoks on 12/19/23.
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
