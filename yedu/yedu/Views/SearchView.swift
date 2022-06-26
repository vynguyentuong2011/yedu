//
//  SearchView.swift
//  yedu
//
//  Created by Nguyen Tuong Vi on 6/26/22.
//

import UIKit
import RxSwift

class SearchView: UIView {
    
    // MARK: - Outlets, Actions
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var separatorHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBAction func textDidChange(_ sender: UITextField) {
        _textChanged.onNext(txtSearch.text ?? "")
    }
    
    // MARK: - Properties
    var placeholder: String = "Search" {
        didSet {
            txtSearch.placeholder = placeholder
        }
    }
    
    var text: String? {
        didSet {
            txtSearch.text = nil
        }
    }
    
    // MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        txtSearch.tintColor = .black
    }
    
    override func becomeFirstResponder() -> Bool {
        return txtSearch.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return txtSearch.resignFirstResponder()
    }
    
    // MARK: - Reactive
    private var _textChanged: PublishSubject<String> = .init()
    var textChanged: Observable<String> {
        return _textChanged.asObservable()
    }
    
    private var _didReturn: PublishSubject<Void> = .init()
    var didReturn: Observable<Void> {
        return _didReturn.asObservable()
    }
    
}

// MARK: - UITextField delegate
extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        _didReturn.onNext(())
        return true
    }
}
