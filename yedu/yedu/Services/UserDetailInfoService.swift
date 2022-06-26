//
//  UserDetailInfoService.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import Foundation
import RxSwift

protocol UserDetailInfoServiceType {
    func getUserDetailInfo(userId: String) -> Observable<UserDetailInfo?>
    func deleteUserDetailInfo(userId: String) -> Observable<String?>
}

final class UserDetailInfoService: UserDetailInfoServiceType {
    func getUserDetailInfo(userId: String) -> Observable<UserDetailInfo?> {
        return UserDetailInfoTargets.FetchUserDetailInfoTarget(userId: userId)
            .execute()
            .map({
                guard let res = $0 else {
                    throw CELoadingError.noResponse
                }
                return res
            })
    }
    
    func deleteUserDetailInfo(userId: String) -> Observable<String?> {
        return UserDetailInfoTargets
            .DeletehUserDetailInfoTarget(userId: userId)
            .execute()
            .map({
                guard let res = $0 else {
                    throw CELoadingError.noResponse
                }
                return res
            })
    }
}

