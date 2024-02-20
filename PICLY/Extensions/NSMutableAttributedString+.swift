//
//  NSMutableAttributedString+.swift
//  PICLY
//
//  Created by JDeoks on 1/7/24.
//

import Foundation

extension NSMutableAttributedString {

    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        
        // 하이퍼링크를 추가하고자 하는 text의 위치, 글자 수를 찾는다.
        let foundRange = self.mutableString.range(of: textToFind)
        
        // text의 위치 존재 여부 확인
        if foundRange.location != NSNotFound {
           
           // 지정된 범위에 문자(링크)를 추가해준다.
           self.addAttribute(.link, value: linkURL, range: foundRange)
           
           // 위치가 맞다면 true 반환
           return true
        }
        
        // 위치가 틀리면 false 반환
        return false
    }
    
}
