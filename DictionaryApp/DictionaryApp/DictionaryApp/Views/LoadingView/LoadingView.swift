//
//  LoadingView.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//


//NOTE: This implementation belongs to Kerim Caglar
//I was already going to do the same things so instead i fetched it
//github: https://github.com/kcaglarr
import UIKit

class LoadingView {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static let shared = LoadingView()
    var blurView: UIVisualEffectView = UIVisualEffectView()
    
    private init() {
        configure()
    }
    
    func configure() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = UIWindow(frame: UIScreen.main.bounds).frame
        activityIndicator.center = blurView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        blurView.contentView.addSubview(activityIndicator)
    }
    
    func startLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            UIApplication.shared.windows.first?.addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            blurView.removeFromSuperview()
            activityIndicator.stopAnimating()
        }
    }
    
}
