//
//  UIImage+Extension.swift
//  PiCo
//
//  Created by JDeoks on 12/25/23.
//

import Foundation
import UIKit

extension UIImage {
    
    func cropSquare() -> UIImage? {
        let imageSize = self.size
        let shortLength = min(imageSize.width, imageSize.height)
        let origin = CGPoint(
            x: imageSize.width / 2 - shortLength / 2,
            y: imageSize.height / 2 - shortLength / 2
        )
        let size = CGSize(width: shortLength, height: shortLength)
        let square = CGRect(origin: origin, size: size)
        guard let squareImage = self.cgImage?.cropping(to: square) else {
            return nil
        }
        return UIImage(cgImage: squareImage)
    }
    
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
