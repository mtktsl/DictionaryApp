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
    
    var meaningsCount: Int { get }
    func definitionsCount(at index: Int) -> Int
    
    func getMeaning(_ index: Int) -> WordMeaningModel?
    func getDetailCellModel(section: Int, row: Int) -> DetailCellModel?
    func queryForWord(_ word: String)
    func navigateToDetail(_ wordModel: WordTopModel)
}

// ---- Class definition ----
final class WordDetailViewModel {
    private(set) var service: DictionaryAPIProtocol?
    private(set) weak var coordinator: HomeCoordinator?
    
    private var wordModel: WordTopModel?
    private var wordSynonyms: [WordSynonymModel]?
    
    weak var delegate: WordDetailViewModelDelegate?
    
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
}

// ---- API request result handlers ----
extension WordDetailViewModel {
    private func onQuerySuccess(_ wordModel: [WordTopModel]) {
        guard let model = wordModel.first else { return }
        coordinator?.navigateToDetail(model)
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
        delegate?.synonymFetchSuccess()
    }
    
    private func onSynonymError(_ error: DictionaryAPIError) {
        delegate?.synonymFetchError(error: error)
    }
}

// ---- Protocol implementation ----
extension WordDetailViewModel: WordDetailViewModelProtocol {
    var wordString: String {
        guard let word = wordModel?.word
        else { return "" }
        
        return word.firstUpperCased()
    }
    
    var phonecticString: String {
        return wordModel?.phonetic ?? ""
    }
    
    var meaningsCount: Int {
        let validCount = wordModel?.meanings?
            .filter({ $0.partOfSpeech != nil }).count
        return validCount ?? 0
    }
    
    func definitionsCount(at index: Int) -> Int {
        let definitionCount = wordModel?.meanings?[index]
            .definitions?
                .filter({ $0.definition != nil }).count
        
        return definitionCount ?? 0
    }
    
    func getMeaning(_ index: Int) -> WordMeaningModel? {
        if index < 0 || index >= meaningsCount {
            return nil
        } else {
            return wordModel?.meanings?[index]
        }
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
