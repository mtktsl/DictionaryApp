//
//  ApplicationConstants.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import DictionaryAPI

struct ApplicationConstants {
    
    static let dictionaryURLConfig = URLConfigurationModel(
        baseURLString: "https://api.dictionaryapi.dev",
        routeString: "api/v2/entries/en",
        querySeperator: "/")
    
    static let synonymURLConfig = URLConfigurationModel(
        baseURLString: "https://api.datamuse.com",
        routeString: "words",
        querySeperator: "?rel_syn=")
}
