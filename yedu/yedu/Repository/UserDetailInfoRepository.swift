//
//  UserDetailInfoRepository.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import Foundation
import RxSwift

protocol UserDetailInfoRepositoryType {
    func getUserDetailInfo(userId: String) -> Observable<UserDetailInfo?>
    func deleteUserDetailInfo(userId: String) -> Observable<String?>
}

final class UserDetailInfoRepository: UserDetailInfoRepositoryType {
    
    let userDetailInfoService: UserDetailInfoServiceType
    
    init(userDetailInfoService: UserDetailInfoServiceType = UserDetailInfoService()) {
        self.userDetailInfoService = userDetailInfoService
    }
    
    func getUserDetailInfo(userId: String) -> Observable<UserDetailInfo?> {
        return self.userDetailInfoService.getUserDetailInfo(userId: userId)
    }
    
    func deleteUserDetailInfo(userId: String) -> Observable<String?> {
        return self.userDetailInfoService.deleteUserDetailInfo(userId: userId)
    }
}
