//
//  UserInfoRepository.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import RxSwift

protocol UserInfoRepositoryType {
    func getUserInfos(isRefresh: Bool,
                      offset: Int) -> Observable<[UserInfo]?>
}

final class UserInfoRepository: UserInfoRepositoryType {
    
    let userInfoService: UserInfoServiceType
    
    init(userInfoService: UserInfoServiceType = UserInfoService()) {
        self.userInfoService = userInfoService
    }
    
    func getUserInfos(isRefresh: Bool, offset: Int) -> Observable<[UserInfo]?> {
        userInfoService.getUserInfos(isRefresh: isRefresh, offset: offset)
    }
}
