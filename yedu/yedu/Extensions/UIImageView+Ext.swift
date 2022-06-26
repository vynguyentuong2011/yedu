//
//  UIImageView+Ext.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import Foundation
import Kingfisher

public protocol CTURLConvertible {
    func asURL() throws -> URL
}

extension String: CTURLConvertible {
    public func asURL() throws -> URL {
        if let url = URL(string: self) {
            return url
        }
        throw(NSError(domain: "Couldn't convert \(self) to URL", code: 0))
    }
}

extension URL: CTURLConvertible {
    public func asURL() throws -> URL { return self }
}

public enum ImageLoaderOptions {
    case scaleDownLargeImages
    case continueInBackground
    case refreshCached
    case retryFailed
    
    func toKingfisherOptions(view: UIView) -> KingfisherOptionsInfo {
        var options = KingfisherOptionsInfo()
        switch self {
        case .scaleDownLargeImages:
            options.append(contentsOf: [
                .processor(DownsamplingImageProcessor(size: view.frame.size)),
                        .scaleFactor(UIScreen.main.scale),
                        .cacheOriginalImage
            ])
        case .continueInBackground:
            break
        case .refreshCached:
            options.append(.forceRefresh)
        case .retryFailed:
            options.append(.retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(1))))
        }
        return options
    }
}

public typealias ImageLoaderCompletion = (Result<UIImage, Error>) -> Void

public extension UIImageView {
    func setImage(with urlConvertable: CTURLConvertible?,
                  placeholder: UIImage? = nil,
                  options: ImageLoaderOptions? = nil,
                  completion: ImageLoaderCompletion? = nil) {
        var url: URL?
        do {
            url = try urlConvertable?.asURL()
        }
        catch {
            
        }
        let opts = options?.toKingfisherOptions(view: self)
        kf.setImage(with: url, placeholder: placeholder, options: opts) { result in
            switch result {
            case .success(let data):
                completion?(.success(data.image))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}

public extension UIButton {
    func setImage(with urlConvertable: CTURLConvertible?,
                  for state: UIControl.State,
                  placeholder: UIImage? = nil,
                  options: ImageLoaderOptions? = nil,
                  completion: ImageLoaderCompletion? = nil) {
        var url: URL?
        do {
            url = try urlConvertable?.asURL()
        }
        catch {
            
        }
        let opts = options?.toKingfisherOptions(view: self)
        kf.setImage(with: url, for: state, placeholder: placeholder, options: opts, completionHandler:  { result in
            switch result {
            case .success(let data):
                completion?(.success(data.image))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }
}

