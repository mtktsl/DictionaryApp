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
    
    var itemCount: Int { get }
    
    func getMeaning(_ index: Int) -> WordMeaningModel?
    func queryForWord(_ word: String)
    func navigateToDetail(_ wordModel: WordTopModel)
}

// ---- Class definition ----
final class WordDetailViewModel {
    private(set) var service: DictionaryAPIProtocol?
    private(set) var coordinator: HomeCoordinator?
    
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
    
    var itemCount: Int {
        return wordModel?.meanings.count ?? 0
    }
    
    func getMeaning(_ index: Int) -> WordMeaningModel? {
        if index < 0 || index >= itemCount {
            return nil
        } else {
            return wordModel?.meanings[index]
        }
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
