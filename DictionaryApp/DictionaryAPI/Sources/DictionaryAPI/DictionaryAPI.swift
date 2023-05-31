import NetworkDataAPI

public protocol DictionaryAPIProtocol {
    
    var sourceURL: DictionaryURL? { get }
    
    func configure(_ url: DictionaryURL)
    func dictionaryQuery(_ word: String,
                         completion:
                         @escaping (Result<[WordTopModel], DictionaryAPIError>
                         ) -> Void)
    
    func synonymQuery(_ word: String,
                      completion:
                      @escaping (Result<[WordSynonymModel], DictionaryAPIError>
                      ) -> Void)
}

public final class DictionaryAPI {
    
    public private(set) var sourceURL: DictionaryURL?
    
    public init(_ url: DictionaryURL) {
        configure(url)
    }
}

extension DictionaryAPI: DictionaryAPIProtocol {
    
    public func dictionaryQuery(_ word: String,
                                completion: @escaping (Result<[WordTopModel], DictionaryAPIError>) -> Void) {
        guard let sourceURL else {
            fatalError("DictionaryAPI hasn't been configured with a URL yet")
        }
        
        DataProviderService.shared.fetchData(
            from: sourceURL.dictionaryBaseURL.generateQueryURLString(word),
            dataType: [WordTopModel].self,
            decode: true
        ) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(.generateError(error)))
            }
        }
    }
    
    public func synonymQuery(_ word: String,
                             completion: @escaping (Result<[WordSynonymModel], DictionaryAPIError>) -> Void) {
        guard let sourceURL else {
            fatalError("DictionaryAPI hasn't been configured with a URL yet")
        }
        
        DataProviderService.shared.fetchData(
            from: sourceURL.synonymBaseURL.generateQueryURLString(word),
            dataType: [WordSynonymModel].self,
            decode: true
        ) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(.generateError(error)))
            }
        }
    }
    
    
    public func configure(_ url: DictionaryURL) {
        self.sourceURL = url
    }
}
