//
//  UserDetailManager.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import UIKit

final class UserDetailManager: NSObject {
    @objc static let shared = UserDetailManager()
    private var navigator: UserDetailNavigateable
    
    private override init() {
        navigator = UserDetailNavigator.shared
        super.init()
        navigator.userDetailCoordinatorDelegate = self
    }
    
    @objc func startViewController(userId: String) -> UIViewController? {
        return navigator.start(userId: userId)
    }
}

extension UserDetailManager: UserDetailNavigatorDelegate {
    func popToVC(id: String, vc: UIViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
