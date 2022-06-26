//
//  UserInfo.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import ObjectMapper

class UserInfo: Mappable {
    var id: String?
    var title: String?
    var firstName: String?
    var lastName: String?
    var picture: String?
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.title <- map["title"]
        self.firstName <- map["firstName"]
        self.lastName <- map["lastName"]
        self.picture <- map["picture"]
    }
    
    required init?(map: Map) {}
    
    init() {
        
    }
}
