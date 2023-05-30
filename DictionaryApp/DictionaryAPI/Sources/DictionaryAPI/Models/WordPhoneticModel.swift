//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation

public struct WordPhoneticModel: Decodable {
    public let text: String?
    public let audioSource: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case audioSource = "audio"
    }
}
