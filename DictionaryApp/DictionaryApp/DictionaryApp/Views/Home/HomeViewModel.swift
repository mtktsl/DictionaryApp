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
    
    fileprivate enum SearchError {
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
    func navigateToDetail(_ word: String)
    
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
            print("Success fetch")
            recentSearches = items.reversed()
        } else {
            print("No fetch")
        }
    }
    
    private func cacheRecentSearch(_ word: String) {
        
        guard let context = coordinator?.appDelegate?.persistentContainer.viewContext
        else { return }
        
        let newItem = RecentSearch(context: context)
        newItem.word = word
        
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
            popupError(title: "Error",
                       message: "Text field is empty",
                       okOption: "Ok")
        case .invalidWord:
            popupError(title: "Error",
                       message: "No query found for the given word",
                       okOption: "Ok")
        case .connectionError(let message, let word):
            popupError(
                title: "Connection Error",
                message: message,
                okOption: "Retry",
                cancelOption: "Cancel"
            ) { [weak self] _ in
                guard let self else { return }
                self.queryForWord(word)
            } cancelHandler: { _ in
                //TODO: pop back to home or remove this handler implementation
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
        if word.isEmpty {
            generateErrorPopUp(.emptyTextField)
        } else {
            //TODO: Send query to the server
            //cacheRecentSearch(word)
            //delegate?.reloadRecentSearches()
            
            service?.dictionaryQuery(word) { [weak self] result in
                guard let self else { return }
                
                switch result {
                
                case .success(_):
                    print("Success")
                    break
                
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        
                        switch error {
                        case .statusCode(let code, _):
                            if code == 404 {
                                self.generateErrorPopUp(.invalidWord)
                            }
                        default:
                            self.generateErrorPopUp(
                                .connectionError(error.description,
                                                 word: word)
                            )
                        }
                    }
                }
            }
        }
    }
    
    func navigateToDetail(_ word: String) {
        cacheRecentSearch(word)
        coordinator?.navigateToDetail(word)
    }
}
