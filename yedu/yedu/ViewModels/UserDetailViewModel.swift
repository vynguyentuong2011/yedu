//
//  UserDetailViewModel.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import UIKit
import RxSwift
import RxRelay
import Action

protocol UserDetailPresentable: AnyObject {
    var listener: UserDetailPresentableListener? { get set }
    var userDetailInfo: BehaviorRelay<UserDetailInfo?> { get set }
}

protocol UserDetailPresentableListener: AnyObject {
    func didBecomeActive()
    var didSelectDeleteButton: PublishRelay<Void> { get }
}

class UserDetailViewModel: UserDetailPresentableListener {
    
    // MARK: Properties
    weak var presenter: UserDetailPresentable?
    private let disposeBag = DisposeBag()
    private let userId: String
    
    // MARK: Dependencies
    private let userDetailInfoRepository: UserDetailInfoRepositoryType
    private lazy var getUserDetailInfoAction = makeGetUserDetailInfoAction(userId: userId)
    private lazy var deleteUserDetailInfoAction = makeDeleteUserDetailInfoAction(userId: userId)
    var didSelectDeleteButton: PublishRelay<Void> = .init()
    var didTapDeleteButton: ((_: String) -> Void)?
    
    // MARK: - Life cycles
    func didBecomeActive() {
        presenter?.listener = self
        configurePresenter()
        configureActions()
        getUserDetailInfoAction.execute()
    }
    
    init(repository: UserDetailInfoRepositoryType, userId: String) {
        self.userId = userId
        self.userDetailInfoRepository = repository
    }
}

private extension UserDetailViewModel {
    func configurePresenter() {
        guard let presenter = presenter else { return }
        getUserDetailInfoAction
            .elements
            .subscribeNext { userDetail in
                guard let userInfoDetail = userDetail else { return }
                presenter.userDetailInfo.accept(userInfoDetail)
            }
            .disposed(by: disposeBag)
        
        deleteUserDetailInfoAction
            .elements
            .subscribeNext { id in
                guard let id = id else { return }
                self.didTapDeleteButton?(id)
            }
            .disposed(by: disposeBag)
    }
    
    func configureActions() {
        didSelectDeleteButton
            .subscribeNext { _ in
                self.deleteUserDetailInfoAction.execute()
            }
            .disposed(by: disposeBag)
    }
    
    func makeGetUserDetailInfoAction(userId: String) -> Action<Void, UserDetailInfo?> {
        return Action<Void, UserDetailInfo?> { [unowned self] _ in
            return self.userDetailInfoRepository
                .getUserDetailInfo(userId: userId)
        }
    }
    
    func makeDeleteUserDetailInfoAction(userId: String) -> Action<Void, String?> {
        return Action<Void, String?> { [unowned self] _ in
            return self.userDetailInfoRepository
                .deleteUserDetailInfo(userId: userId)
        }
    }
}
