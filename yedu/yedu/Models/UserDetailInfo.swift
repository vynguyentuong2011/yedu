//
//  UserDetailInfo.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import Foundation
import ObjectMapper

class UserDetailInfo: Mappable {
    var userInfo: UserInfo?
    var email: String?
    var dateOfBirth: String?
    
    typealias Dict = [String: Any]
    
    func mapping(map: Map) {
        self.userInfo = parseUserInfo(from: map.JSON)
        self.email <- map["email"]
        self.dateOfBirth <- map["dateOfBirth"]
    }
    
    required init?(map: Map) {}
    
    init() {
        
    }
    
    private func parseUserInfo(from dict: Dict) -> UserInfo? {
        return UserInfo(JSON: dict)
    }
}
