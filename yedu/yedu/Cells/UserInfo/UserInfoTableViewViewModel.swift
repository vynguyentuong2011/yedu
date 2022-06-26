//
//  UserInfoTableViewViewModel.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

protocol UserInfoPresentable: AnyObject {
    var userInfo: BehaviorRelay<UserInfo?> { get }
}

protocol UserInfoPresentableListener: AnyObject {
    var presenter: UserInfoPresentable? { get set }
    func didBecomeActive()
}

class UserInfoTableViewViewModel: ListUserCellViewModelType, UserInfoPresentableListener {
    var identity: String = "UserInfoTableViewViewModel"
    
    // MARK: - Properties
    weak var presenter: UserInfoPresentable?
    weak var listening: UserInfoPresentableListener? {
        return self
    }
    var bag = DisposeBag()
    let userInfo: UserInfo
    let position: Int
    
    init(userInfo: UserInfo, position: Int) {
        self.userInfo = userInfo
        self.position = position
    }
    
    func didBecomeActive() {
        bag = DisposeBag()
        configurePresenter()
    }
    
    private func configurePresenter() {
        guard let presenter = self.presenter else {
            return
        }
        presenter.userInfo.accept(userInfo)
    }
}
