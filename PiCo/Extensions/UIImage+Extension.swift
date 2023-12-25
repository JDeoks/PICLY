//
//  UIImage+Extension.swift
//  PiCo
//
//  Created by JDeoks on 12/25/23.
//

import Foundation
import UIKit

extension UIImage {
    
    func resize(targetSize: CGSize) -> UIImage {
        let newWidth = targetSize.width
        let newheight = targetSize.height
        let size = CGSize(width: newWidth, height: newheight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
}
