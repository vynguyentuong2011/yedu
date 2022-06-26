//
//  UserDetailViewController.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import UIKit
import RxSwift
import RxRelay

class UserDetailViewController: BaseViewController, UserDetailPresentable {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @objc static func instantiate() -> UserDetailViewController {
        UIStoryboard(
            name: "ListUser",
            bundle: Bundle(for: UserDetailViewController.self)
        ).instantiateViewController(
            withIdentifier: String(describing: UserDetailViewController.self)
        ) as! UserDetailViewController
    }
    
    weak var listener: UserDetailPresentableListener?
    var viewModel: UserDetailViewModel?
    var userDetailInfo: BehaviorRelay<UserDetailInfo?> = .init(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureViewModel()
        configureListener()
    }
    
    private func configureUI() {
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 5
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = 20
    }
    
    private func configureViewModel() {
        viewModel?.presenter = self
        viewModel?.didBecomeActive()
        
        userDetailInfo
            .subscribeNext { [weak self] userDetail in
                guard let self = self, let userDetail = userDetail else {
                    return
                }
                if let imageURL = URL(string: userDetail.userInfo?.picture ?? "") {
                    self.userImageView.setImage(with: imageURL)
                }
                
                if let firstName = userDetail.userInfo?.firstName, let lastName = userDetail.userInfo?.lastName {
                    self.nameLabel.text = firstName + " " + lastName
                }
                
                if let email = userDetail.email {
                    self.emailLabel.text = email
                }
                
                if let dateOfBirth = userDetail.dateOfBirth {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions.insert(.withFractionalSeconds)
                    let date = formatter.date(from: dateOfBirth)
                    let newFormatter = DateFormatter()
                    newFormatter.dateFormat = "yyyy-MM-dd"
                    let birthdayStr = newFormatter.string(from: date ?? Date())
                    self.birthDayLabel.text = "\(birthdayStr)"
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configureListener() {
        guard let listener = listener else { return }
        
        deleteButton.rx.tap
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: {  _ in
                listener.didSelectDeleteButton.accept(Void())
            }).disposed(by: disposeBag)
    }
}
