//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation

public struct WordMeaningModel: Decodable {
    let partOfSpeech: String?
    let definitions: [WordDefinitionModel]
}

public struct WordDefinitionModel: Decodable {
    let definition: String?
}