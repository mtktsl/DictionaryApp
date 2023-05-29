import NetworkDataAPI

public protocol DictionaryAPIProtocol {
    
    var sourceURL: DictionaryURL? { get }
    
    func configure(_ url: DictionaryURL)
    func dictionaryQuery(_ word: String,
                         completion:
                         @escaping (Result<[WordTopModel], DataProviderServiceError>
                         ) -> Void)
    
    func synonymQuery(_ word: String,
                      completion:
                      @escaping (Result<[WordSynonymModel], DataProviderServiceError>
                      ) -> Void)
}

public class DictionaryAPI {
    
    public var sourceURL: DictionaryURL?
    
    public static let shared: DictionaryAPIProtocol = DictionaryAPI()
    
    private init() { }
}

extension DictionaryAPI: DictionaryAPIProtocol {
    
    public func dictionaryQuery(_ word: String,
                                completion: @escaping (Result<[WordTopModel], NetworkDataAPI.DataProviderServiceError>) -> Void) {
        guard let sourceURL else {
            fatalError("DictionaryAPI hasn't been configured with a URL yet")
        }
        
        DataProviderService.shared.fetchData(
            from: sourceURL.dictionaryBaseURL.generateQueryURLString(word),
            dataType: [WordTopModel].self,
            decode: true,
            completion: completion
        )
    }
    
    public func synonymQuery(_ word: String,
                             completion: @escaping (Result<[WordSynonymModel], NetworkDataAPI.DataProviderServiceError>) -> Void) {
        guard let sourceURL else {
            fatalError("DictionaryAPI hasn't been configured with a URL yet")
        }
        
        DataProviderService.shared.fetchData(
            from: sourceURL.synonymBaseURL.generateQueryURLString(word),
            dataType: [WordSynonymModel].self,
            decode: true,
            completion: completion
        )
    }
    
    
    public func configure(_ url: DictionaryURL) {
        self.sourceURL = url
    }
}
