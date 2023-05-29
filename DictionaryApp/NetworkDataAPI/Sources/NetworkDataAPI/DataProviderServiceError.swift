//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 18.05.2023.
//

import Foundation

public enum DataProviderServiceError: Error {
    case statusCode(_ code: Int)
    case noResponse
    case emptyResponse
    case decodeError
    case typeMissMatchError
    case urlError
    
    public var localizedDescription: String? {
        switch self {
        case .statusCode(let code):
            return "Connection error with status code: \(code)"
        case .noResponse:
            return "Connection error: No response from the server."
        case .emptyResponse:
            return "Connection error: Server response was empty."
        case .decodeError:
            return "Data provided by the server is not decodable to the given type."
        case .typeMissMatchError:
            return "Type missmatch between the given type and the server response."
        case .urlError:
            return "Connection error: Connection URL is not valid."
        }
    }
}
