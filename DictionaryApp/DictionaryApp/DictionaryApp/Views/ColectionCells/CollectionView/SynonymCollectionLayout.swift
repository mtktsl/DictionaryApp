//
//  SynonymCollectionLayout.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//

import UIKit

//This implementation is not mine and belongs to Angel G. Olloqui's answer on stackoverflow
//link: https://stackoverflow.com/a/36016798

//The purpase her is to align cells to left
class SynonymCollectionLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?
            .map {
                $0.copy() as! UICollectionViewLayoutAttributes
            }
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
