//
//  HomeViewModel.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import CoreData
import DictionaryAPI

extension HomeViewModel {
    fileprivate enum HomeVMConstants {
        static let cacheCapacity = 5
        static let searchImageName = "search"
        static let searchButtonTitle = "Search"
        static let recentSearchLabelText = "Recent search"
        static let searchFieldPlaceHolder = "Search"
    }
    fileprivate enum SearchError: Error {
        case emptyTextField
        case invalidWord
        case connectionError(_ message: String,
                             word: String)
    }
}

protocol HomeViewModelDelegate: AnyObject {
    func reloadRecentSearches()
}

protocol HomeViewModelProtocol: AnyObject {
    
    var delegate: HomeViewModelDelegate? { get set }
    var service: DictionaryAPIProtocol? { get }
    
    var itemCount: Int { get }
    var searchImageName: String { get }
    var searchButtonTitle: String { get }
    var recentSearchLabelText: String { get }
    var searchFieldPlaceHolder: String { get }
    
    func getRecentSearch(_ index: Int) -> String?
    func queryForWord(_ word: String)
    func navigateToDetail(_ wordModel: WordTopModel)
    
    func popupError(title: String,
                    message: String,
                    okOption: String?,
                    cancelOption: String?,
                    okHandler: ((Any?) -> Void)?,
                    cancelHandler: ((Any?) -> Void)?)
}

final class HomeViewModel {
    
    private(set) var recentSearches = [RecentSearch]()
    private(set) weak var coordinator: HomeCoordinator?
    private(set) var service: DictionaryAPIProtocol?
    weak var delegate: HomeViewModelDelegate?
    
    init(coordinator: HomeCoordinator,
         service: DictionaryAPIProtocol) {
        self.coordinator = coordinator
        self.service = service
        fetchRecentSearches()
    }
    
    private func fetchRecentSearches() {
        guard let context = coordinator?.appDelegate?.persistentContainer.viewContext
        else { return }
        
        if let items = try? context.fetch(RecentSearch.fetchRequest()) {
            recentSearches = items.reversed()
        }
    }
    
    private func cacheRecentSearch(_ word: String) {
        
        guard let context = coordinator?.appDelegate?.persistentContainer.viewContext
        else { return }
        
        let upperWord = word.firstUpperCased()
        
        if !recentSearches.filter(
            { recentSearch in
                if let recentWord = recentSearch.word {
                    return recentWord == upperWord
                } else {
                    return false
                }
            }
        ).isEmpty {
            return
        }
        
        let newItem = RecentSearch(context: context)
        newItem.word = upperWord
        
        if recentSearches.count == HomeVMConstants.cacheCapacity {
            let item = recentSearches.removeLast()
            context.delete(item)
        }
        
        do {
            try context.save()
            recentSearches.insert(newItem, at: 0)
        } catch {
            print("Recent search could not be saved")
        }
    }
    
    private func generateErrorPopUp(_ error: SearchError) {
        switch error {
        case .emptyTextField:
            popupError(
                title: "Error",
                message: "Text field is empty"
            )
        case .invalidWord:
            popupError(
                title: "Error",
                message: "No query found for the given word"
            )
        case .connectionError(let message, let word):
            popupError(
                title: "Connection Error",
                message: message,
                okOption: "Retry",
                cancelOption: "Cancel"
            ) { [weak self] _ in
                guard let self else { return }
                self.queryForWord(word)
            } cancelHandler: { [weak self] _ in
                guard let _ = self else { return }
            }
        }
    }
    
    private func onQuerySuccess(_ wordModel: [WordTopModel]) {
        guard let firstModel = wordModel.first else { return }
        guard let word = firstModel.word else { return }
        
        cacheRecentSearch(word)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.reloadRecentSearches()
            self.coordinator?.navigateToDetail(firstModel)
        }
    }
    
    private func mergeDuplicatePartOfSpeech(_ model: WordTopModel) -> WordTopModel? {
        //TODO: Implement this method
        let result = [WordMeaningModel]()
        return nil
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
}

extension HomeViewModel: HomeViewModelProtocol {

    var itemCount: Int {
        return recentSearches.count
    }
    
    var searchImageName: String {
        return HomeVMConstants.searchImageName
    }
    
    var searchButtonTitle: String {
        return HomeVMConstants.searchButtonTitle
    }
    
    var recentSearchLabelText: String {
        return HomeVMConstants.recentSearchLabelText
    }
    
    var searchFieldPlaceHolder: String {
        return HomeVMConstants.searchFieldPlaceHolder
    }
    
    func getRecentSearch(_ index: Int) -> String? {
        if index >= itemCount || index < 0 {
            return nil
        } else {
            return recentSearches[index].word
        }
    }
    
    func popupError(
        title: String,
        message: String,
        okOption: String? = nil,
        cancelOption: String? = nil,
        okHandler: ((Any?) -> Void)? = nil,
        cancelHandler: ((Any?) -> Void)? = nil
    ) {
        coordinator?.popupError(
            title: title,
            message: message,
            okOption: okOption,
            cancelOption: cancelOption,
            onOk: okHandler,
            onCancel: cancelHandler)
    }
    
    func queryForWord(_ word: String) {
        
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedWord.isEmpty {
            generateErrorPopUp(.emptyTextField)
        } else {
            coordinator?.showLoading()
            service?.dictionaryQuery(trimmedWord) { [weak self] result in
                guard let self else { return }
                self.coordinator?.hideLoading()
                switch result {
                case .success(let data):
                    self.onQuerySuccess(data)
                
                case .failure(let error):
                    self.onQueryError(trimmedWord, error: error)
                }
            }
        }
    }
    
    func navigateToDetail(_ wordModel: WordTopModel) {
        coordinator?.navigateToDetail(wordModel)
    }
}
