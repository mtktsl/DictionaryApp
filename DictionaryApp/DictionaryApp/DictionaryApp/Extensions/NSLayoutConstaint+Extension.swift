//
//  NSLayoutConstaint+Extension.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 1.06.2023.
//

import UIKit

enum NSLayoutAlignment {
    case top
    case left
    case bottom
    case right
    case fill
}

extension NSLayoutConstraint {
    static func expand(
        _ subView: UIView,
        to rootView: UIView,
        alignment: NSLayoutAlignment = .fill,
        padding: UIEdgeInsets = .zero
    ) {
        var constraints = [NSLayoutConstraint]()
        
        let top = subView.topAnchor.constraint(
            equalTo: rootView.topAnchor,
            constant: padding.top
        )
        
        let left = subView.leadingAnchor.constraint(
            equalTo: rootView.leadingAnchor,
            constant: padding.left
        )
        
        let bottom = subView.bottomAnchor.constraint(
            equalTo: rootView.bottomAnchor,
            constant: -padding.bottom
        )
        
        let right = subView.trailingAnchor.constraint(
            equalTo: rootView.trailingAnchor,
            constant: -padding.right
        )
        
        switch alignment {
        case .top:
            constraints = [top, left, right]
        case .left:
            constraints = [top, left, bottom]
        case .bottom:
            constraints = [left, bottom, right]
        case .right:
            constraints = [bottom, right, top]
        case .fill:
            constraints = [top, left, bottom, right]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    static func expand(
        _ subView: UIView,
        to rootView: UILayoutGuide,
        alignment: NSLayoutAlignment,
        padding: UIEdgeInsets = .zero
    ) {
        var constraints = [NSLayoutConstraint]()
        
        let top = subView.topAnchor.constraint(
            equalTo: rootView.topAnchor,
            constant: padding.top
        )
        
        let left = subView.leadingAnchor.constraint(
            equalTo: rootView.leadingAnchor,
            constant: padding.left
        )
        
        let bottom = subView.bottomAnchor.constraint(
            equalTo: rootView.bottomAnchor,
            constant: padding.bottom
        )
        
        let right = subView.trailingAnchor.constraint(
            equalTo: rootView.trailingAnchor,
            constant: padding.right
        )
        
        switch alignment {
        case .top:
            constraints = [top, left, right]
        case .left:
            constraints = [top, left, bottom]
        case .bottom:
            constraints = [left, bottom, right]
        case .right:
            constraints = [bottom, right, top]
        case .fill:
            constraints = [top, left, bottom, right]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}
