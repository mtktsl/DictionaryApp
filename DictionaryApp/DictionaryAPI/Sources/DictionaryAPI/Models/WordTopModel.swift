//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation

public struct WordTopModel: Decodable {
    public let word: String?
    public let phonetic: String?
    public let phonetics: [WordPhoneticModel]
    public let meanings: [WordMeaningModel]
}
