//
//  UserDetailNavigator.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public protocol UserDetailNavigatorDelegate: AnyObject {
    func popToVC(id: String, vc: UIViewController)
}

public protocol UserDetailNavigateable {
    var userDetailCoordinatorDelegate: UserDetailNavigatorDelegate? { get set }
    func start(userId: String) -> UIViewController?
}

public final class UserDetailNavigator: NSObject, UserDetailNavigateable {
    
    
    
    let disposeBag = DisposeBag()
    public var userDetailCoordinatorDelegate: UserDetailNavigatorDelegate?
    public static let shared = UserDetailNavigator()
    let userDetailRepository: UserDetailInfoRepositoryType = UserDetailInfoRepository(userDetailInfoService: UserDetailInfoService())
    public var navigationController: UINavigationController?
    
    private override init() {
        super.init()
    }
    
    public func start(userId: String) -> UIViewController? {
        let userDetailVC = UserDetailViewController.instantiate()
        let userDetailVM = UserDetailViewModel(repository: userDetailRepository, userId: userId)
        userDetailVM.didTapDeleteButton = { id in
            self.userDetailCoordinatorDelegate?.popToVC(id: id, vc: userDetailVC)
        }
        userDetailVC.viewModel = userDetailVM
        self.navigationController = UINavigationController(rootViewController: userDetailVC)
        return userDetailVC
    }
}

