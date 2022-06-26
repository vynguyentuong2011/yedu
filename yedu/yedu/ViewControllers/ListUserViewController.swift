//
//  ListUserViewController.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit
import RxDataSources
import RxRelay
import RxSwift
import Action

struct ListUserSection: AnimatableSectionModelType {
    
    init(original: ListUserSection, items: [ListUserItem]) {
        self = original
        self.items = items
    }
    
    typealias Identity = String
    typealias Item = ListUserItem
    
    init(items: [ListUserItem]) {
        self.items = items
    }

    var key: String = ""
    var items: [ListUserItem] = []
    var identity: String = ""
}

enum ListUserItem: IdentifiableType, Equatable {
    static func == (lhs: ListUserItem, rhs: ListUserItem) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    var identity: String {
        return viewModel.identity
    }
    
    var viewModel: ListUserCellViewModelType {
        switch self {
        case let .userInfo(vm):
            return vm
        }
    }
    
    case userInfo(_ viewModel: UserInfoTableViewViewModel)
}

class ListUserViewController: BaseViewController, ListUserPresentable {
    
    @objc static func instantiate() -> ListUserViewController {
        UIStoryboard(
            name: "ListUser",
            bundle: Bundle(for: ListUserViewController.self)
        ).instantiateViewController(
            withIdentifier: String(describing: ListUserViewController.self)
        ) as! ListUserViewController
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    private let loadMoreView: LoadMoreView = LoadMoreView.fromNib().then {
        $0.isHidden = true
    }
    
    private lazy var emptyView: EmptyView = EmptyView.fromNib()
    
    private let searchView: SearchView = .fromNib()
    var isSearching: Bool = false
    weak var listener: ListUserPresentableListener?
    var viewModel: ListUserViewModel?
    var sections: BehaviorRelay<[ListUserSection]> = .init(value: [])
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<ListUserSection> = makeDataSource()
    var isLoading: BehaviorRelay<Bool> = .init(value: false)
    var isLoadMore: BehaviorRelay<Bool> = .init(value: false)
    var isCanLoadMore: BehaviorRelay<Bool> = .init(value: false)
    var id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupSearchView()
        configureViewModel()
        configureEvents()
        configureListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureIQKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.listener?.refreshTrigger.accept(())
    }
    
    private func configureUI() {
        self.setupTableView()
    }
    
    private final func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorColor = tableView.backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 0)
        tableView.scrollIndicatorInsets = .zero
        tableView.registerNib(UserInfoTableViewCell.self)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = loadMoreView
    }
    
    private func setupSearchView() {
        guard let viewModel = self.viewModel else {
            return
        }
        tableView.tableHeaderView = searchView
        searchView.txtSearch.autocapitalizationType = .words
        searchView.didReturn
            .subscribe(onNext: { [weak self] in
                _ = self?.searchView.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        searchView.textChanged
            .subscribe(onNext: { [weak self] changedValue in
                self?.isSearching = !changedValue.isEmpty
                self?.viewModel?.searchKeyDidChanged(changedValue)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureViewModel() {
        viewModel?.presenter = self
        viewModel?.router = self
        viewModel?.didBecomeActive()
        
        isLoading
            .subscribeNext { [weak self] _ in
                self?.refreshControl.do {
                    if $0.isRefreshing { $0.endRefreshing() }
                }
            }.disposed(by: disposeBag)
        
        sections
            .asDriver()
            .do(afterNext: { [weak self] _ in
                self?.startCacheTableCellSize()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func configureEvents() {
        guard let listener = self.listener else { return }
        tableView.rx.itemSelected
            .subscribeNext { ip in
                listener.didSelectIndexPath.accept(ip)
            }
            .disposed(by: disposeBag)
    }
    
    func configureListener() {
        Observable.combineLatest(isCanLoadMore, sections)
            .subscribeNext { [weak self] (canLoadMore, data) in
                guard let self = self else { return }
                if canLoadMore && !self.isSearching {
                    self.tableView.tableFooterView = self.loadMoreView
                    self.loadMoreView.isHidden = false
                } else if data.isEmpty {
                    self.tableView.tableFooterView = self.emptyView
                } else {
                    self.tableView.tableFooterView = nil
                }
            }.disposed(by: disposeBag)
        
        isLoadMore.subscribeNext { [weak self] loadMore in
            self?.loadMoreView.start(loadMore)
        }.disposed(by: disposeBag)
    }
    
    func startCacheTableCellSize() {
        tableView.layoutIfNeeded()
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates {
                tableView.reloadData()
            } completion: { _ in
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func refresh() {
        if self.refreshControl.isRefreshing {
            self.listener?.refreshTrigger.accept(())
        }
    }
}

extension ListUserViewController: ListUserFriendRouter {
    
}

extension ListUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section >= sections.value.count - 1 && isCanLoadMore.value && isLoadMore.value == false && !isSearching {
            listener?.loadMoreTrigger.accept(())
        }
    }
}

// MARK: - RxDataSource
extension ListUserViewController {
    fileprivate final func makeDataSource() -> RxTableViewSectionedReloadDataSource<ListUserSection> {
        return .init { [weak self] (_, tableView, indexPath, item) -> UITableViewCell in
            guard self != nil else {
                return UITableViewCell()
            }
            
            switch item {
                case .userInfo(let vm):
                let cell: UserInfoTableViewCell = tableView.dequeueCell(for: indexPath)
                cell.bind(to: vm)
                return cell
            }
        }
    }
}
