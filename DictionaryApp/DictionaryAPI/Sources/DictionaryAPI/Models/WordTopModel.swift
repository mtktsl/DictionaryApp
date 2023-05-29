//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation

public struct WordTopModel: Decodable {
    let word: String?
    let phonetic: String?
    let phonetics: [WordPhoneticModel]
    let meanings: [WordMeaningModel]
}
