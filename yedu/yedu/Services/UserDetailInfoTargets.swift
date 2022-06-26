//
//  UserDetailInfoTargets.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import Foundation
import ObjectMapper
import Alamofire

enum UserDetailInfoTargets {
    struct FetchUserDetailInfoTarget: Requestable {
        typealias Output = UserDetailInfo?
        var httpMethod: HTTPMethod { return .get }
        typealias Dict = [String: Any]
        
        var endpoint: String {
            return Constants.UserInfoAPIEndpoint.getUserInfoList + "/\(userId)"
        }
        
        var headers: HTTPHeaders {
            return [
                "app-id": "62b15627b5f714ca950dc979"
            ]
        }
        
        let userId: String
        
        func decode(data: Any) -> Output {
            guard let response = data as? Dict else {
                return nil
            }
            return UserDetailInfo(JSON: response)
        }
    }
    
    struct DeletehUserDetailInfoTarget: Requestable {
        typealias Output = String?
        var httpMethod: HTTPMethod { return .delete }
        typealias Dict = [String: Any]
        
        var endpoint: String {
            return Constants.UserInfoAPIEndpoint.getUserInfoList + "/\(userId)"
        }
        
        var headers: HTTPHeaders {
            return [
                "app-id": "62b15627b5f714ca950dc979"
            ]
        }
        
        let userId: String
        
        func decode(data: Any) -> Output {
            guard let response = data as? Dict else {
                return nil
            }
            
            guard let id = response["id"] as? String else {
                return nil
            }
            return id
        }
    }
}
