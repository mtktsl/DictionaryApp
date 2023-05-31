//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 30.05.2023.
//

import Foundation
import NetworkDataAPI

public enum DictionaryAPIError : Error {
    case statusCode(_ code: Int, responseData: Data?)
    case noResponse
    case emptyResponse
    case decodeError
    case typeMissMatchError
    case urlError

    public var localizedDescription: String {
        switch self {
        case .statusCode(let code, _):
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
    
    internal static func generateError(_ error: DataProviderServiceError) -> Self {
        switch error {
        case .statusCode(let code, let responseData):
            return .statusCode(code, responseData: responseData)
        case .noResponse:
            return .noResponse
        case .emptyResponse:
            return emptyResponse
        case .decodeError:
            return .decodeError
        case .typeMissMatchError:
            return .typeMissMatchError
        case .urlError:
            return .urlError
        }
    }
}
