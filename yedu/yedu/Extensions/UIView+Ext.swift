//
//  UIView+Ext.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import UIKit

public extension UIView {
    class func fromNib() -> Self {
        return Bundle(for: self.self).loadNibNamed(String(describing: self.self), owner: nil, options: nil)![0] as! Self
    }
}
