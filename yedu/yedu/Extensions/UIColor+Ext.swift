//
//  UIColor+Ext.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit

public extension UIColor {
    @objc convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.hasPrefix("0x".uppercased()) {
            cString.remove(at: cString.startIndex)
            cString.remove(at: cString.startIndex)
        }
        
        assert((cString.count) == 6, "Invalid color")
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        let rgb = Int(rgbValue)
        
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF),
            green: CGFloat((rgb >> 8) & 0xFF),
            blue: CGFloat(rgb & 0xFF), alpha: 1
        )
    }
}
