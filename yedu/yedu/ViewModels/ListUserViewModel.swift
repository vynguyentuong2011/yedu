//
//  ListUserViewModel.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import RxSwift
import RxRelay
import Action

protocol ListUserPresentable: AnyObject {
    var listener: ListUserPresentableListener? { get set }
    var sections: BehaviorRelay<[ListUserSection]> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    var isLoadMore: BehaviorRelay<Bool> { get }
    var isCanLoadMore: BehaviorRelay<Bool> { get }
}

protocol ListUserPresentableListener: AnyObject {
    var loadMoreTrigger: PublishRelay<Void> { get }
    var refreshTrigger: PublishRelay<Void> { get }
    var searchKey: BehaviorRelay<String> { get set }
    func searchKeyDidChanged(_ newValue: String)
    var didSelectIndexPath: PublishRelay<IndexPath> { get }
    func didBecomeActive()
}

protocol ListUserFriendRouter: AnyObject {
    
}

class ListUserViewModel: ListUserPresentableListener {
    
    // MARK: Properties
    weak var presenter: ListUserPresentable?
    weak var router: ListUserFriendRouter?
    private let disposeBag = DisposeBag()
    var sections: [ListUserSection] = []
    private var currentOffset: Int = 0
    var currentUserInfos = BehaviorRelay<[UserInfo]>(value: [])
    var searchCurrentUserInfos = BehaviorRelay<[UserInfo]>(value: [])
    var isSearching = false
    
    // MARK: Triggers
    var loadMoreTrigger = PublishRelay<Void>()
    var refreshTrigger = PublishRelay<Void>()
    var didSelectIndexPath: PublishRelay<IndexPath> = .init()
    
    // MARK: Dependencies
    private let userInfoRepository: UserInfoRepositoryType
    private lazy var refreshUserInfoAction = buildGetUserInfoAction(isRefresh: true)
    private lazy var getMoreUserInfoAction = buildGetUserInfoAction(isRefresh: false)
    
    // MARK: Search
    var searchKey: BehaviorRelay<String> = .init(value: "")
    var didSelectUser: ((_: String) -> Void)?
    
    // MARK: - Life cycles
    func didBecomeActive() {
        presenter?.listener = self
        configureTrigger()
        configurePresenter()
        refreshUserInfoAction.execute()
        resetData()
    }
    
    init(repository: UserInfoRepositoryType) {
        self.userInfoRepository = repository
    }
    
    func searchKeyDidChanged(_ newValue: String) {
        isSearching = !newValue.isEmpty
        searchKey.accept(newValue)
    }
    
    func resetData() {
        searchKey
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] searchString in
                guard let self = self else { return }
                self.handleEmptyKeyword(searchString)
            })
            .subscribeNext { [weak self] searchString in
                guard let self = self, !searchString.isEmpty else { return }
                let validUserInfos = self.currentUserInfos.value.filter { userInfo in
                    let name = (userInfo.lastName ?? "") + " " + (userInfo.firstName ?? "")
                    return (name.lowercased().range(of: searchString.lowercased()) != nil)
                }
                self.searchCurrentUserInfos.accept(validUserInfos)
                self.presenter?.sections.accept(validUserInfos.enumerated().flatMap { self.makeSectionsFor(userInfo: $0.element, position: $0.offset) })
            }
            .disposed(by: disposeBag)
    }
    
    private func handleEmptyKeyword(_ key: String) {
        guard key.isEmpty else { return }
        let validUserInfos = self.currentUserInfos.value
        presenter?.sections.accept(validUserInfos.enumerated().flatMap { self.makeSectionsFor(userInfo: $0.element, position: $0.offset) })
    }
}

private extension ListUserViewModel {
    func configureTrigger() {
        refreshTrigger
            .subscribeNext { [weak self] _ in
                self?.refreshUserInfoAction.execute()
            }
            .disposed(by: disposeBag)
        
        loadMoreTrigger
            .subscribeNext { [weak self] _ in
                self?.getMoreUserInfoAction.execute()
            }
            .disposed(by: disposeBag)
    }
    
    func configurePresenter() {
        guard let presenter = presenter else { return }
        refreshUserInfoAction
            .elements
            .subscribeNext { [weak self] users in
                guard let self = self else { return }
                let results = users ?? []
                self.currentOffset += 1
                self.currentUserInfos.accept(results)
                self.presenter?.sections.accept(results.enumerated().flatMap { self.makeSectionsFor(userInfo: $0.element, position: $0.offset) })
                self.presenter?.isCanLoadMore.accept(!results.isEmpty)
            }
            .disposed(by: disposeBag)
        
        getMoreUserInfoAction
            .elements
            .subscribeNext { [weak self] users in
                guard let self = self else { return }
                if let users = users {
                    var sections = self.presenter?.sections.value ?? []
                    var results = self.currentUserInfos.value
                    let startOffset = results.count
                    results.append(contentsOf: users)
                    self.currentOffset += 1
                    sections.append(contentsOf: users.enumerated().flatMap { self.makeSectionsFor(userInfo: $0.element, position: $0.offset + startOffset) })
                    self.currentUserInfos.accept(results)
                    self.presenter?.sections.accept(sections)
                }
                self.presenter?.isCanLoadMore.accept(users?.isEmpty == false)
            }
            .disposed(by: disposeBag)
        
        getMoreUserInfoAction
            .executing
            .bind(to: presenter.isLoadMore)
            .disposed(by: disposeBag)
        
        refreshUserInfoAction
            .executing
            .bind(to: presenter.isLoading)
            .disposed(by: disposeBag)
        
        refreshUserInfoAction
            .errors
            .retry()
            .map {_ in false }
            .bind(to: presenter.isCanLoadMore)
            .disposed(by: disposeBag)
        
        didSelectIndexPath
            .map({ [weak self] indexPath -> UserInfo? in
                guard let userInfo = self?.userInfoFor(indexPath) else {
                    return nil
                }
                return userInfo
            })
            .subscribeNext { [weak self] userInfo in
                guard let userId = userInfo?.id else {
                    return
                }
                self?.didSelectUser?(userId)
            }
            .disposed(by: disposeBag)
            
    }
    
    private func userInfoFor(_ indexPath: IndexPath) -> UserInfo? {
        guard currentUserInfos.value.count >= indexPath.section else {
            return nil
        }
        if isSearching {
            return searchCurrentUserInfos.value[indexPath.section]
        }
        return currentUserInfos.value[indexPath.section]
    }
    
    func buildGetUserInfoAction(isRefresh: Bool) -> Action<Void, [UserInfo]?> {
        return Action<Void, [UserInfo]?> { [unowned self] _ in
            if isRefresh {
                self.currentOffset = 0
            }
            return self.userInfoRepository.getUserInfos(isRefresh: isRefresh, offset: currentOffset)
        }
    }
}

extension ListUserViewModel {
    func makeSectionsFor(userInfo: UserInfo, position: Int) -> [ListUserSection] {
        [
            ListUserSection(items: [userInfoItem(userInfo: userInfo, position: position)])
        ]
    }
    
    func userInfoItem(userInfo: UserInfo, position: Int) -> ListUserItem {
        let vm = UserInfoTableViewViewModel(userInfo: userInfo, position: position)
        return .userInfo(vm)
    }
}
