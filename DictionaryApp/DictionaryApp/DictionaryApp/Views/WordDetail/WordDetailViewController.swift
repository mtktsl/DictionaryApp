//
//  WordDetailViewController.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import UIKit

class WordDetailViewController: UIViewController {
    
    var viewModel: WordDetailViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "HELLO FROM DETAIL"
        
        label.frame = view.bounds
        view.addSubview(label)
    }
}

extension WordDetailViewController: WordDetailViewModelDelegate {
    func synonymFetchSuccess() {
        
    }
    
    func synonymFetchError(error: Error) {
        
    }
    
    func soundFetchSuccess() {
        
    }
    
    func soundFetchError() {
        
    }
}
