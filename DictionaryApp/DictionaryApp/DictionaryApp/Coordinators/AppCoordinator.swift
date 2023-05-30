//
//  AppCoordinator.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import UIKit

final class AppCoordinator: CoordinatorProtocol {
    
    private(set) var appDelegate: AppDelegate?
    
    private(set) var navigationController: UINavigationController?
    private(set) var childCoordinators: [CoordinatorProtocol] = []
    
    init(navigationController: UINavigationController?,
         appDelegate: AppDelegate?) {
        self.navigationController = navigationController
        self.appDelegate = appDelegate
    }
    
    func start() {
        guard let navigationController else {
            fatalError("NavigationController instance for AppCoordinator hasn't been set.")
        }
        
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            appDelegate: appDelegate
        )
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
    
    func endEditting() {
        navigationController?.topViewController?.view.endEditing(true)
    }
}
