//
//  FilterSelector.swift
//  
//
//  Created by Metin Tarık Kiki on 28.05.2023.
//

import Foundation

public protocol FilterSelectorDelegate: AnyObject {
    func onFilterSelected(_ filter: String)
    func onFilterRemoved(_ filter: String)
    func onFilterClear()
}
