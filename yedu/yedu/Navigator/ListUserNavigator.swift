//
//  ListUserNavigator.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public protocol ListUserNavigatorDelegate: AnyObject {
    func navigateToUserDetail(userId: String)
}

public protocol ListUserNavigateable {
    var listUserCoordinatorDelegate: ListUserNavigatorDelegate? { get set }
    func start() -> UIViewController?
}

public final class ListUserNavigator: NSObject, ListUserNavigateable {
    
    let disposeBag = DisposeBag()
    public var listUserCoordinatorDelegate: ListUserNavigatorDelegate?
    public static let shared = ListUserNavigator()
    let listUserRepository: UserInfoRepositoryType = UserInfoRepository(userInfoService: UserInfoService())
    public var navigationController: UINavigationController?
    
    private override init() {
        super.init()
    }
    
    public func start() -> UIViewController? {
        let listUserVC = ListUserViewController.instantiate()
        let listUserVM = ListUserViewModel(repository: listUserRepository)
        listUserVM.didSelectUser = { [weak self] userId in
            self?.listUserCoordinatorDelegate?.navigateToUserDetail(userId: userId)
        }
        listUserVC.viewModel = listUserVM
        self.navigationController = listUserVC.navigationController
        return listUserVC
    }
}

