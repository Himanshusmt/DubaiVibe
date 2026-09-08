//
//  UIColorExtension.swift
//  MyGuardianLink
//
//  Created by Aasif on 13/06/26.
//

import UIKit

extension UIColor {
    
    static let primaryBlue = UIColor(hex: "#074E77")
    static let shadowBlue = UIColor(hex: "#102A43")
    
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
