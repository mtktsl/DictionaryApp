//
//  UIFont+Extension.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//

import UIKit

//NOTE: I added this solution in 2.06.2023 to this project.
//NOTE2: This solution is belong to Maksymilian Wojakowski's answer at stackoverflow.
//Link: https://stackoverflow.com/a/21777132
extension UIFont {
    var bold: UIFont {
        return with(.traitBold)
    }
    
    var italic: UIFont {
        return with(.traitItalic)
    }
    
    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }
    
    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor
            .withSymbolicTraits(
                UIFontDescriptor.SymbolicTraits(traits)
                    .union(self.fontDescriptor.symbolicTraits))
        else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor
            .withSymbolicTraits(
                self.fontDescriptor
                    .symbolicTraits
                        .subtracting(
                            UIFontDescriptor
                                .SymbolicTraits(traits)
                        )
            ) else { return self }
        
        return UIFont(descriptor: descriptor, size: 0)
    }
}
