//
//  Constants.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation

public class Constants {
    enum Config {
        static var baseURL = "https://dummyapi.io/"
        static let timeout = TimeInterval(30 * 1000)
        
    }
    
    public enum APIResponseStatus: String {
        case success = "success"
        case error   = "error"
    }
}

extension Constants {
    public enum UserInfoAPIEndpoint {
        static let getUserInfoList = "data/v1/user"
    }
    
    struct APIConfig {
        static let PageSize = 10
    }
}
