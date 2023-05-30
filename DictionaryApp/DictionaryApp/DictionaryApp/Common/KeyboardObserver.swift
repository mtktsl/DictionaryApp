//
//  KeyboardDragger.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 30.05.2023.
//

import UIKit

class KeyboardObserver {
    
    private(set) weak var observer: UIViewController?
    private(set) var isKeyboardOpen = false
    private(set) var windowHeight: CGFloat = 0
    
    init(observer: UIViewController) {
        self.observer = observer
    }
    
    func windowChanged(_ newWindowHeight: CGFloat) {
        windowHeight = newWindowHeight
    }
    
    func startResizingObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        if !isKeyboardOpen {
            resizeViewWithKeyboard(notification: notification,
                                isOpening: true)
            isKeyboardOpen = true
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        if isKeyboardOpen {
            resizeViewWithKeyboard(notification: notification,
                                   isOpening: false)
            isKeyboardOpen = false
        }
    }
    
    private func resizeViewWithKeyboard(
        notification: NSNotification,
        isOpening: Bool
    ) {
        guard let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue
        )?.cgRectValue
        else { return }
        
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
                as? Double
        else { return }
        
        guard let rawCurveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]
                as? Int
        else { return }
        
        guard let animationCurve = UIView.AnimationCurve(
            rawValue: rawCurveValue
        )
        else { return }
        
        let animator = UIViewPropertyAnimator(
            duration: animationDuration,
            curve: animationCurve
        ) { [weak self] in
            guard let self else { return }
            if isOpening {
                observer?.view.frame.size.height -= keyboardSize.height
            } else {
                observer?.view.frame.size.height = self.windowHeight
            }
        }
        animator.startAnimation()
    }
}
