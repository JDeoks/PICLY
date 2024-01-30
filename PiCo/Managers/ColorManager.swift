//
//  ColorManager.swift
//  PiCo
//
//  Created by JDeoks on 1/12/24.
//

import Foundation
import UIKit

class ColorManager {
    
    static let shared = ColorManager()
    private init() { }
    
    let mainText: UIColor! = UIColor(named: "MainText")
    let secondText: UIColor! = UIColor(named: "SecondText")
    let collectionViewCellButton: UIColor! = UIColor(named: "CollectionViewCellButton")
    let mainBackground: UIColor! = UIColor(named: "MainBackground")
    let collectionViewCellBackground: UIColor! = UIColor(named: "CollectionViewCellBackground")
    let floatButtonBackground: UIColor! = UIColor(named: "FloatButtonBackground")
    let textFieldBackground: UIColor! = UIColor(named: "TextFieldBackground")
    let highlightBlue: UIColor! = UIColor(named: "HighlightBlue")
    let warnRed: UIColor! = UIColor(named: "WarnRed")
    let appleLoginBackground: UIColor! = UIColor(named: "AppleLoginBackground")
    
}
