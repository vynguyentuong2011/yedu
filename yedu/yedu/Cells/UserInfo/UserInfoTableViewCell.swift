//
//  UserInfoTableViewCell.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

class UserInfoTableViewCell: UITableViewCell, UserInfoPresentable {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    var bag = DisposeBag()
    weak var listener: UserInfoPresentableListener?
    private weak var presenting: UserInfoPresentable? {
        return self
    }
    var userInfo: BehaviorRelay<UserInfo?> = .init(value: nil)
    
    private var viewModel: UserInfoTableViewViewModel? {
        didSet {
            listener = viewModel
            viewModel?.presenter = self
            viewModel?.didBecomeActive()
        }
    }
    
    func bind(to viewModel: UserInfoTableViewViewModel) {
        self.viewModel = viewModel
        self.configurePresenter()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = 20
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 20))
    }
    
    private func configurePresenter() {
        guard let presenter = self.presenting else {
            return
        }
        
        presenter.userInfo
            .asDriver()
            .drive(onNext: { [weak self] userInfo in
                guard let self = self, let userInfo = userInfo else {
                    return
                }
                if let urlImage = URL(string: userInfo.picture ?? ""), let firstName = userInfo.firstName, let lastName = userInfo.lastName {
                    self.userImageView.setImage(with: urlImage)
                    self.nameLabel.text = firstName + " " + lastName
                }
            })
            .disposed(by: bag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
}
