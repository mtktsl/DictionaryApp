import Foundation

public protocol DataProviderServiceProtocol: AnyObject {
    func fetchData<T: Decodable>(from urlString: String,
                                 dataType: T.Type,
                                 decode: Bool,
                                 completion: @escaping (Result<T, DataProviderServiceError>) -> Void)
}

public class DataProviderService: DataProviderServiceProtocol {
    
    public static let shared: DataProviderServiceProtocol = DataProviderService()
    
    private init() {}
    
    public func fetchData<T: Decodable>(from urlString: String,
                                        dataType: T.Type = Data.self,
                                        decode: Bool = false,
                                        completion: @escaping (Result<T, DataProviderServiceError>) -> Void) {
        
        guard let url = URL(string: urlString)
        else {
            completion(.failure(.urlError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let response = response as? HTTPURLResponse
            else {
                completion(.failure(.noResponse))
                return
            }
            
            if response.statusCode < 200 || response.statusCode > 299 {
                completion(.failure(.statusCode(response.statusCode,
                                                responseData: data)))
                return
            }
            
            guard let data
            else {
                completion(.failure(.emptyResponse))
                return
            }
            
            if !decode {
                if let data = data as? T {
                    completion(.success(data))
                } else {
                    completion(.failure(.typeMissMatchError))
                }
                
            } else if let resultData = try? JSONDecoder().decode(T.self,
                                                                 from: data) {
                completion(.success(resultData))
            } else {
                completion(.failure(.decodeError))
            }
            
        }.resume()
    }
}
