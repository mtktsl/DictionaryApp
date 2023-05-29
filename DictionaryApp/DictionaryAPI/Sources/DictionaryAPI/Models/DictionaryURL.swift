//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation

public struct DictionaryURL {
    public let dictionaryBaseURL: URLConfigurationModel
    public let synonymBaseURL: URLConfigurationModel
    
    public init(dictionaryBaseURL: URLConfigurationModel,
                synonymBaseURL: URLConfigurationModel) {
        self.dictionaryBaseURL = dictionaryBaseURL
        self.synonymBaseURL = synonymBaseURL
    }
}
