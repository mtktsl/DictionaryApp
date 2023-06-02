//
//  WordDetailViewModel.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import DictionaryAPI

// ---- Constants ----
extension WordDetailViewModel {
    fileprivate enum DetailVMConstants {
        static let synonymTitle = "Synonym"
        static let maxSynonymNum = 5
    }
    
    fileprivate enum DetailQueryError: Error {
        case invalidWord
        case connectionError(_ message: String,
                             word: String)
    }
}

// ---- Delegate ----
protocol WordDetailViewModelDelegate: AnyObject {
    func synonymFetchSuccess()
    func synonymFetchError(error: Error)
    func soundFetchSuccess()
    func soundFetchError()
}

// ---- Protocol definition ----
protocol WordDetailViewModelProtocol: AnyObject {
    
    var delegate: WordDetailViewModelDelegate? { get set }
    
    var wordString: String { get }
    var phonecticString: String { get }
    var filterStrings: [String] { get set }
    
    var meaningsCount: Int { get }
    var isSynonymAvailable: Bool { get }
    
    func definitionsCount(at index: Int) -> Int
    
    func getMeaning(_ index: Int) -> WordMeaningModel?
    func getDetailCellModel(section: Int, row: Int) -> DetailCellModel?
    func getSynonymCellModel() -> SynonymCellModel
    func queryForWord(_ word: String)
    func navigateToDetail(_ wordModel: WordTopModel)
    func getPartOfSpeeches() -> [String]
}

// ---- Class definition ----
final class WordDetailViewModel {
    private(set) var service: DictionaryAPIProtocol?
    private(set) weak var coordinator: HomeCoordinator?
    
    private var synonymSuccess = false
    private var wordModel: WordTopModel?
    private var wordSynonyms: [WordSynonymModel]?
    
    weak var delegate: WordDetailViewModelDelegate?
    
    var filterStrings: [String] = [String]() {
        didSet {
            filteredWords = filteredMeanings()
        }
    }
    
    var filteredWords: [WordMeaningModel]?
    
    init(coordinator: HomeCoordinator,
         service: DictionaryAPIProtocol,
         wordModel: WordTopModel) {
        self.coordinator = coordinator
        self.service = service
        self.wordModel = wordModel
        
        queryForSynonym(wordModel.word)
    }
    
    private func queryForSound() {
        //TODO: query for sound
    }
    
    private func queryForSynonym(_ word: String?) {
        guard let word else { return }
        service?.synonymQuery(word) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.onSynonymSuccess(data)
            case .failure(let error):
                self.onSynonymError(error)
            }
        }
    }
    
    private func generateErrorPopUp(_ error: DetailQueryError) {
        switch error {
        case .invalidWord:
            self.coordinator?.popupError(
                title: "Error",
                message: "Word entry is invalid."
            )
        case .connectionError(let errorMessage, let word):
            self.coordinator?.popupError(
                title: "Connection Error",
                message: errorMessage,
                okOption: "Retry",
                cancelOption: "Cancel",
                onOk: { [weak self] _ in
                    self?.queryForWord(word)
                }
            )
        }
    }
    
    private func filteredMeanings() -> [WordMeaningModel] {
        var result = [WordMeaningModel]()
        for meaning in wordModel?.meanings ?? [] {
            if let partOfSpeech = meaning.partOfSpeech {
                if filterStrings.contains(partOfSpeech) {
                    result.append(meaning)
                }
            }
        }
        
        return result
    }
}

// ---- API request result handlers ----
extension WordDetailViewModel {
    private func onQuerySuccess(_ wordModel: [WordTopModel]) {
        guard let model = wordModel.first else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.coordinator?.navigateToDetail(model)
        }
    }
    
    private func onQueryError(_ word: String, error: DictionaryAPIError) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            switch error {
            case .statusCode(let code, _):
                if code == 404 {
                    self.generateErrorPopUp(.invalidWord)
                }
            default:
                self.generateErrorPopUp(
                    .connectionError(error.localizedDescription,
                                     word: word)
                )
            }
        }
    }
    
    private func onSynonymSuccess(_ synonyms: [WordSynonymModel]) {
        self.wordSynonyms = synonyms
        synonymSuccess = true
        delegate?.synonymFetchSuccess()
    }
    
    private func onSynonymError(_ error: DictionaryAPIError) {
        synonymSuccess = false
        delegate?.synonymFetchError(error: error)
    }
}

// ---- Protocol implementation ----
extension WordDetailViewModel: WordDetailViewModelProtocol {
    
    var isSynonymAvailable: Bool {
        return !(wordSynonyms?.isEmpty ?? true)
    }
    
    
    var wordString: String {
        guard let word = wordModel?.word
        else { return "" }
        
        return word.firstUpperCased()
    }
    
    var phonecticString: String {
        
        if let phonetic = wordModel?.phonetic {
            return phonetic
        } else {
            
            for text in wordModel?.phonetics ?? [] {
                if let result = text.text {
                    return result
                }
            }
        }
        return ""
    }
    
    var meaningsCount: Int {
        
        if filteredWords?.isEmpty ?? true {
            let validCount = wordModel?.meanings?
                .filter({ $0.partOfSpeech != nil }).count
            
            let result = validCount ?? 0
            
            return wordSynonyms?.count ?? 0 > 0 ? result + 1 : result
        } else {
            let validCount = filteredWords?
                .filter({$0.partOfSpeech != nil}).count
            
            let result = validCount ?? 0
            
            return wordSynonyms?.count ?? 0 > 0 ? result + 1 : result
        }
    }
    
    func definitionsCount(at index: Int) -> Int {
        
        if filteredWords?.isEmpty ?? true {
            
            if let count = wordModel?.meanings?.count {
                if index >= count {
                    return 1
                }
            }
            
            let definitionCount = wordModel?.meanings?[index]
                .definitions?
                    .filter({ $0.definition != nil }).count
            
            return definitionCount ?? 0
            
        } else {
            
            if let count = filteredWords?.count {
                if index >= count {
                    return 1
                }
            }
            
            let definitionCount = filteredWords?[index]
                .definitions?
                    .filter({ $0.definition != nil }).count
            
            return definitionCount ?? 0
        }
        
        
        
    }
    
    func getMeaning(_ index: Int) -> WordMeaningModel? {
        if index < 0 || index >= meaningsCount {
            return nil
        } else {
            if filteredWords?.isEmpty ?? true {
                return wordModel?.meanings?[index]
            } else {
                return filteredWords?[index]
            }
        }
    }
    
    func getPartOfSpeeches() -> [String] {
        var result = [String]()
        for meaning in wordModel?.meanings ?? [] {
            if let speech = meaning.partOfSpeech {
                result.append(speech)
            }
        }
        return result
    }
    
    func getDetailCellModel(section: Int, row: Int) -> DetailCellModel? {
        guard let meaning = getMeaning(section)
        else { return nil }
        guard let definition = meaning.definitions?[row]
        else { return nil }
        guard let partOfSpeech = meaning.partOfSpeech
        else { return nil }
        guard let explanation = definition.definition
        else { return nil }
        
        return .init(
            number: row+1,
            partOfSpeech: partOfSpeech.firstUpperCased(),
            meaning: explanation,
            example: definition.example
        )
    }
    
    func getSynonymCellModel() -> SynonymCellModel {
        
        var words = [String]()
        for synonymModel in wordSynonyms ?? [] {
            if let synonymWord = synonymModel.word {
                words.append(synonymWord)
            }
        }
        
        return .init(title: DetailVMConstants.synonymTitle,
                     synonyms: words,
                     maxItemNum: DetailVMConstants.maxSynonymNum)
    }
    
    func queryForWord(_ word: String) {
        service?.dictionaryQuery(word) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.onQuerySuccess(data)
            case .failure(let error):
                self.onQueryError(word, error: error)
            }
        }
    }
    
    func navigateToDetail(_ wordModel: WordTopModel) {
        coordinator?.navigateToDetail(wordModel)
    }
}
