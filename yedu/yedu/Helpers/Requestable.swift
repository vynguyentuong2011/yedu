//
//  Requestable.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire

public enum CELoadingError: Error {
    case noInternet
    case noResponse
    case notFound(_ message: String?)
    case otherError(_ message: String?, dataRes: [String: Any]? = nil, displayMessage: String?)
}

struct CEAlamofire {
    static var `default` = CEAlamofire()
    private init() {}
    
    lazy var sessionManager: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = HTTPHeaders.default
        return Alamofire.Session(configuration: configuration)
    }()
}


protocol Requestable: URLRequestConvertible {
    associatedtype Output
    var basePath: String { get }
    
    var endpoint: String { get }
    
    var httpMethod: HTTPMethod { get }
    
    var params: Parameters { get }
    
    var headers: HTTPHeaders { get }
    
    var parameterEncoding: ParameterEncoding { get }
    
    func decode(data: Any) -> Output
}

extension Requestable {
    var basePath: String {
        return Constants.Config.baseURL
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var params: Parameters {
        return [:]
    }
    
    var urlPath: String {
        return basePath + endpoint
    }
    
    var url: URL {
        return URL(string: urlPath)!
    }
    
    var headers: HTTPHeaders {
        return [:]
    }
    
    var parameterEncoding: ParameterEncoding {
        switch httpMethod {
        case .post, .put, .delete:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    func execute() -> Observable<Output> {
        return asObservable()
    }
    
    func asURLRequest() throws -> URLRequest {
        return try buildURLRequest()
    }
    
    fileprivate func buildURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.timeoutInterval = Constants.Config.timeout
        urlRequest = try parameterEncoding.encode(urlRequest, with: params)
        
        headers.forEach { header in
            urlRequest.addValue(header.value, forHTTPHeaderField: header.name)
        }
        
        return urlRequest
    }
    
    private func asObservable() -> Observable<Output> {
        return Observable.create { observer in
            guard let urlRequest = try? self.asURLRequest() else {
                let errorResponse = CELoadingError.notFound("")
                observer.onError(errorResponse)
                return Disposables.create()
            }
            
            let connection = self.connectWithRequest(urlRequest, complete: { response in
                debugPrint(response)
                switch response.result {
                case let .success(data):
                    if let data = data,
                       let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        observer.onNext(self.decode(data: dict))
                        observer.onCompleted()
                    } else {
                        observer.onError(self.error(ofReponse: response,
                                                    statusCode: nil,
                                                    error: nil))
                    }

                case let .failure(error):
                    var httpStatusCode: HTTPStatusCode?
                    if let statusCode = response.response?.statusCode {
                        httpStatusCode = HTTPStatusCode(rawValue: statusCode)
                    }
                    let errorResponse = self.error(
                        ofReponse: response,
                        statusCode: httpStatusCode,
                        error: error)
                    
                    observer.onError(errorResponse)
                }
            })
            
            return Disposables.create {
                connection?.cancel()
            }
        }
    }
    
    func connectWithRequest(
        _ urlRequest: URLRequest,
        complete: @escaping (AFDataResponse<Data?>) -> Void
    ) -> DataRequest? {
        
        let sessionManager = CEAlamofire.default.sessionManager
        
        return httpRequest(urlRequest: urlRequest,
                           sessionManager: sessionManager,
                           complete: complete)
    }
    
    private func httpRequest(
        urlRequest: URLRequest,
        sessionManager: Session,
        complete: @escaping (AFDataResponse<Data?>) -> Void
        ) -> DataRequest {
        let request = sessionManager.request(urlRequest)

        debugPrint(request)

        requestData(request: request, complete: complete)
    
        return request
    }
    
    private func requestData(
        request: DataRequest,
        complete: @escaping (AFDataResponse<Data?>) -> Void
    ) {
        request
            .response(completionHandler: { response in
                complete(response)
            })
    }
}

extension Requestable {
    func error(ofReponse response: (Alamofire.AFDataResponse<Data?>)?, statusCode: HTTPStatusCode?, error: Error?) -> CELoadingError {
        
        let httpStatusCode = HTTPStatusCode(rawValue: response?.response?.statusCode ?? 0) ?? .notFound
        
        if let data = response?.data,
           let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            var message = ""
            var displayMessage = ""
            if let messageResponse = jsonError["message"] as? String {
                message = messageResponse
            }
            
            if let displayMessageResponse = jsonError["display_message"] as? String {
                displayMessage = displayMessageResponse
            }
            
            return .otherError(message, dataRes: jsonError, displayMessage: displayMessage)
        }
        
        if let err = error as? URLError,
           (err.code == .notConnectedToInternet
                || err.code == .networkConnectionLost
                || err.code == .cannotLoadFromNetwork) {
            return .noInternet
        }
        
        if httpStatusCode == .notFound {
            return .notFound("")
        }
        
        return .otherError(
            "",
            dataRes: nil,
            displayMessage: nil
        )
    }
}

public enum HTTPStatusCode: Int {
    /// 200 Success
    case ok = 200
    case notFound
}
