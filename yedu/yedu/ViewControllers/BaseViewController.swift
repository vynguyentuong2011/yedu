//
//  BaseViewController.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit
import RxSwift
import IQKeyboardManagerSwift

class BaseViewController: UIViewController {
    
    // MARK: - rx
    var disposeBag = DisposeBag()
    
    // MARK: - keyboard
    
    func configureIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
        IQKeyboardManager.shared.toolbarBarTintColor = .white
        IQKeyboardManager.shared.toolbarTintColor = .init(hex: "0x2675EC")
    }
    
    func disableIQKeyboard() {
        IQKeyboardManager.shared.enable = false
    }
}
