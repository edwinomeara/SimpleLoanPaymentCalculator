//
//  Helpers.swift
//  LoanCalculator
//
//  Created by Edwin  O'Meara on 6/23/18.
//  Copyright © 2018 Edwin  O'Meara. All rights reserved.
//
import UIKit
import Foundation

extension UIView {

func addConstraintsWithFormat(format: String, views: UIView...) {
    var viewsDictionary = [String: UIView]()
    for(index, view) in views.enumerated() {
        let key = "v\(index)"
        view.translatesAutoresizingMaskIntoConstraints = false
        viewsDictionary[key] = view
    }
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
}
}
