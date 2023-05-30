//
//  WordDetailViewController.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import Foundation
import UIKit

class WordDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "HELLO FROM DETAIL"
        
        label.frame = view.bounds
    }
}
