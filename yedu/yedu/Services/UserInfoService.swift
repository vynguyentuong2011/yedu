//
//  UserInfoService.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import RxSwift

protocol UserInfoServiceType {
    func getUserInfos(isRefresh: Bool,
                      offset: Int) -> Observable<[UserInfo]?>
}

final class UserInfoService: UserInfoServiceType {
    
    let executionScheduler: SchedulerType
    let resultScheduler: SchedulerType
    
    public init(
        executionScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()),
        resultScheduler: SchedulerType = MainScheduler.instance
    ) {
        self.executionScheduler = executionScheduler
        self.resultScheduler = resultScheduler
    }

    func getUserInfos(isRefresh: Bool, offset: Int) -> Observable<[UserInfo]?> {
        UserInfoTargets.FetchUserInfoListTarget(offsetPage: offset, isRefresh: isRefresh)
            .execute()
            .observe(on: resultScheduler)
    }
}
