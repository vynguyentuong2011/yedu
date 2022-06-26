//
//  Observable+bind.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import RxSwift
import RxCocoa

public extension ObservableType {
    func subscribeNext(_ onNext: @escaping (Element) -> Void) -> Disposable {
        return self.subscribe(onNext: onNext)
    }
}
