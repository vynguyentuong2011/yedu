//
//  ListUserManager.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import UIKit

final class ListUserManager: NSObject {
    @objc static let shared = ListUserManager()
    private var navigator: ListUserNavigateable
    
    private override init() {
        navigator = ListUserNavigator.shared
        super.init()
        navigator.listUserCoordinatorDelegate = self
    }
    
    @objc func startViewController() -> UIViewController? {
        return navigator.start()
    }
}

extension ListUserManager: ListUserNavigatorDelegate {
    func navigateToUserDetail(userId: String) {
        let detailUserVC = UserDetailManager.shared.startViewController(userId: userId) ?? UIViewController()
        ListUserNavigator.shared.navigationController?.pushViewController(detailUserVC, animated: true)
    }
}
