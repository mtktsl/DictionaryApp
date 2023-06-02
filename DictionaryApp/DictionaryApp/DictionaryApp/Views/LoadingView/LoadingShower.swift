//
//  LoadingShower.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//

import UIKit

protocol LoadingShower: AnyObject {
    func showLoading()
    func hideLoading()
}

extension LoadingShower {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
