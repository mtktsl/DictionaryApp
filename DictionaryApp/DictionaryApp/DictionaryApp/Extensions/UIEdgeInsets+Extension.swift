//
//  UIEdgeInsets+Extension.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 28.05.2023.
//

import UIKit

extension UIEdgeInsets {
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
    
    init(_ inset: CGFloat) {
        self.init(inset, inset, inset, inset)
    }
}
