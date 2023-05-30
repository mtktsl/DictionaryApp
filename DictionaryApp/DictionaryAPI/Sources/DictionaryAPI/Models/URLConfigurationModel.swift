//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation

public struct URLConfigurationModel {
    public let baseURLString: String
    public let routeString: String
    public let querySeperator: String
    
    public func generateQueryURLString(_ queryString: String) -> String {
        return baseURLString
        + "/" + routeString
        + querySeperator
        + (queryString.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
        ) ?? "-")
    }
    
    public init(baseURLString: String,
                routeString: String,
                querySeperator: String) {
        self.baseURLString = baseURLString
        self.routeString = routeString
        self.querySeperator = querySeperator
    }
}
