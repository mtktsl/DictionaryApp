//
//  UIEdgeInsets+Extension.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 28.05.2023.
//

import UIKit

extension UIEdgeInsets {
    
    init(_ inset: CGFloat) {
        self.init(inset, inset, inset, inset)
    }
    
    init(_ top: CGFloat = 0,
         _ left: CGFloat = 0,
         _ bottom: CGFloat = 0,
         _ right: CGFloat = 0
    ) {
        self.init(top: top,
                  left: left,
                  bottom: bottom,
                  right: right)
    }
}

extension UIEdgeInsets {
    static let homeSearchImageMargin = UIEdgeInsets(16, 15, 16)
    static let homeSearchTextMargin = UIEdgeInsets(0, 14)
    static let homeSearchBarMargin = UIEdgeInsets(0, 20, 0, 20)
    static let homeRecentLabelMargin = UIEdgeInsets(30, 20)
    static let homeCollectionViewMargin = UIEdgeInsets(30, 20, 0, 20)
    static let recentCellImageMargin = UIEdgeInsets(11, 0, 11, 25)
    static let recentCellArrowMargin = UIEdgeInsets(11, 25, 11)
}
