//
//  Coordinator.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get }
    var navigationController: UINavigationController? { get }
    var appDelegate: AppDelegate? { get }
    func start()
}
