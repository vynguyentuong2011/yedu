//
//  UserInfoTargets.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import ObjectMapper
import Alamofire

enum UserInfoTargets {
    struct FetchUserInfoListTarget: Requestable {
        typealias Output = [UserInfo]?
        var httpMethod: HTTPMethod { return .get }
        
        var endpoint: String {
            return Constants.UserInfoAPIEndpoint.getUserInfoList + "?page=\(offsetPage)&limit=\(limit)"
        }
        
        var headers: HTTPHeaders {
            return [
                "app-id": "62b15627b5f714ca950dc979"
            ]
        }
        
        let limit: Int = Constants.APIConfig.PageSize
        let offsetPage: Int
        let isRefresh: Bool
        
        func decode(data: Any) -> Output {
            return Mapper<UserInfo>()
                .mapArray(JSONObject: (data as? [String: Any])?["data"])
        }
    }
    
}
