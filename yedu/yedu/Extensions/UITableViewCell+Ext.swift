//
//  UITableViewCell+Ext.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit

// MARK: - Register cell helper
public extension UITableView {
    func registerNib<T: UITableViewCell>(_ nibClassType: T.Type, bundle: Bundle? = nil) {
        let id = String(describing: nibClassType.self)
        let nib = UINib(nibName: id, bundle: bundle ?? Bundle(for: T.self))
        register(nib, forCellReuseIdentifier: id)
    }
    
    func dequeueCell<T: UITableViewCell>(_ classType: T.Type = T.self, for indexPath: IndexPath) -> T {
        let id = String(describing: classType.self)
        return (dequeueReusableCell(withIdentifier: id, for: indexPath) as! T)
    }
}
