//
//  Binding.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 31.05.2023.
//

import Foundation

class ChangeObserver {
    
    var kvoTokens = [NSKeyValueObservation?]()
    
    func startListening<T: NSObject, T2: Any>(
        _ owner: T,
        source: KeyPath<T, T2>,
        onChange: @escaping (T2?) -> Void
    ) {
        let token = owner.observe(
            source,
            options: .new
        ) { object, change in
            onChange(change.newValue)
        }
        
        kvoTokens.append(token)
    }
    
    //Documentation says that tokens should be invalidated before deallocated
    deinit {
        for token in kvoTokens {
            token?.invalidate()
        }
    }
}
