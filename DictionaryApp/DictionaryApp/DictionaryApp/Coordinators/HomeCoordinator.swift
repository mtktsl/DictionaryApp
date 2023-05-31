//
//  HomeCoordinator.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import UIKit
import DictionaryAPI

final class HomeCoordinator: CoordinatorProtocol {
    
    private(set) var appDelegate: AppDelegate?
    private(set) var childCoordinators: [CoordinatorProtocol] = []
    private(set) var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController,
         appDelegate: AppDelegate?) {
        self.navigationController = navigationController
        self.appDelegate = appDelegate
        
    }
    
    func start() {
        let homeVC = HomeViewController()
        homeVC.viewModel = HomeViewModel(
            coordinator: self,
            service: DictionaryAPI(
                .init(dictionaryBaseURL: ApplicationConstants.dictionaryURLConfig,
                      synonymBaseURL: ApplicationConstants.synonymURLConfig)
            )
        )
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func popupError(
        title: String,
        message: String,
        okOption: String? = nil,
        cancelOption: String? = nil,
        onOk: ((UIAlertAction) -> Void)? = nil,
        onCancel: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: okOption ?? "OK",
            style: .default,
            handler: onOk
        )
        alertVC.addAction(okAction)
        
        if let cancelOption {
            let exitAction = UIAlertAction(
                title: cancelOption,
                style: .destructive,
                handler: onCancel
            )
            alertVC.addAction(exitAction)
        }
        
        navigationController?.present(alertVC, animated: true)
    }
    
    func navigateToDetail(_ wordModel: WordTopModel) {
        
        let detailVC = WordDetailViewController()
        
        let service = DictionaryAPI(
            .init(dictionaryBaseURL: ApplicationConstants.dictionaryURLConfig,
                  synonymBaseURL: ApplicationConstants.synonymURLConfig)
        )
        
        detailVC.viewModel = WordDetailViewModel(
            coordinator: self,
            service: service,
            wordModel: wordModel
        )
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
