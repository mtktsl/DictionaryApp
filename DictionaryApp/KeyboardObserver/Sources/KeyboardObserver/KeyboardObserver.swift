//
//  KeyboardDragger.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 30.05.2023.
//

import UIKit

public class KeyboardObserver {
    
    public private(set) weak var observerController: UIViewController?
    public private(set) var isKeyboardOpen = false
    public private(set) var windowHeight: CGFloat = 0
    
    public init(_ observerController: UIViewController) {
        self.observerController = observerController
    }
    
    deinit {
        self.stopResizingObserver()
    }
    
    public func startResizingObserver() {
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
    
    public func stopResizingObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillAppear(_ notification: NSNotification) {
        if !isKeyboardOpen {
            setWindowHeightBuffer()
            resizeViewWithKeyboard(notification: notification,
                                   isOpening: true)
            isKeyboardOpen = true
        }
    }
    
    @objc private func keyboardWillDisappear(_ notification: NSNotification) {
        if isKeyboardOpen {
            setWindowHeightBuffer()
            resizeViewWithKeyboard(notification: notification,
                                   isOpening: false)
            isKeyboardOpen = false
        }
    }
    
    private func setWindowHeightBuffer() {
        windowHeight = observerController?.view.window?.screen.bounds.size.height ?? 0
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
                observerController?.view.frame.size.height -= keyboardSize.height
            } else {
                observerController?.view.frame.size.height = self.windowHeight
            }
        }
        animator.startAnimation()
    }
}
