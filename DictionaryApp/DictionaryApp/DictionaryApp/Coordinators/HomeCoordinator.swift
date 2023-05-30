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
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)? = nil,
        onCancel: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if let okOption {
            let okAction = UIAlertAction(
                title: okOption,
                style: .default,
                handler: onOk
            )
            alertVC.addAction(okAction)
        }
        
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
    
    func navigateToDetail(_ word: String) {
        let detailVC = WordDetailViewController()
        //TODO: add viewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
