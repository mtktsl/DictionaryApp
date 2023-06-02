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
        
        //Target of this packes is IOS v12 so we have to use "whiteLarge" instead of "large"
        activityIndicator.style = .whiteLarge
        blurView.contentView.addSubview(activityIndicator)
    }
    
    func startLoading() {
        UIApplication.shared.windows.first?.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.blurView.removeFromSuperview()
            self.activityIndicator.stopAnimating()
        }
    }
}
