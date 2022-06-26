//
//  EmptyView.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/25/22.
//

import UIKit

class EmptyView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 15
    }
}
