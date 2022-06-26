//
//  LoadMoreView.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import Foundation
import UIKit

public final class LoadMoreView: UIView {
    
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(hex: "#F4F4F4")
    }
    
    public func startLoading() {
        activityIndicatorView.startAnimating()
    }
    
    public func stopLoading() {
        activityIndicatorView.stopAnimating()
    }
    
    public func start(_ isStart: Bool) {
        if isStart {
            startLoading()
        }
        else {
            stopLoading()
        }
    }
}
