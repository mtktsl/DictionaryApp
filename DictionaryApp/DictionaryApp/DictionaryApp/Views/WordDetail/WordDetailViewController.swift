//
//  WordDetailViewController.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 29.05.2023.
//

import UIKit
import GridLayout
import FilterSelector

class WordDetailViewController: UIViewController {
    
    var viewModel: WordDetailViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    var isFooterAvailable = false
    
    let tableView: UITableView = UITableView(frame: .zero,
                                             style: .plain)
    
    lazy var wordLabel: UILabel = {
        let wordLabel = UILabel()
        wordLabel.text = viewModel.wordString
        wordLabel.font = .boldSystemFont(ofSize: 36)
        wordLabel.numberOfLines = 0
        return wordLabel
    }()
    
    lazy var phoneticLabel: UILabel = {
        let phoneticLabel = UILabel()
        phoneticLabel.text = viewModel.phonecticString
        phoneticLabel.font = .boldSystemFont(ofSize: 11)
        return phoneticLabel
    }()
    
    let soundImageView: UIImageView = {
        let playSoundImageView = UIImageView(image: UIImage(named: "pronunciation"))
        playSoundImageView.contentMode = .scaleAspectFit
        
        playSoundImageView.layer.shadowRadius = 10
        playSoundImageView.layer.shadowColor = UIColor.systemGray3.cgColor
        playSoundImageView.layer.shadowOffset = .init(width: 0, height: 1)
        playSoundImageView.layer.shadowOpacity = 0.5
        
        return playSoundImageView
    }()
    
    //TODO: Get filters from viewModel
    let filterSelector = FilterSelector(
        cancelImage: UIImage(systemName: "xmark"),
        borderColor: .systemGray3,
        borderSelectionColor: .homeButtonColor)
    
    let filterScrollView = UIScrollView()
    
    lazy var headerGrid = Grid.vertical {
        Grid.horizontal {
            
            Grid.vertical {
                
                wordLabel
                    .Auto(margin: .init(4, 20))/*horizontalAlignment: .autoLeft, */
                
                phoneticLabel
                    .Auto(margin: .init(13, 20))
            }.Expanded()
            
            soundImageView
                .Auto(margin: .init(5, 0, 0, 5))
        }.Auto()
        
        filterScrollView
            .Constant(value: 59, margin: .init(5, 20, 20))
    }
    
    lazy var mainGrid = Grid.vertical {
        headerGrid
            .Auto()
        
        tableView
            .Expanded()
    }
    
    let frameObserver = ChangeObserver()
}

// ---- Function Implementations ----
extension WordDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        headerGrid.backgroundColor = .detailHeaderBackgroundColor
        
        view.addSubview(mainGrid)
        
        filterSelector.filters = viewModel.getPartOfSpeeches()
        setupTableView()
        
        //The reason i'm starting an observation vor view frame is that i realized that the view frame is being incosistend when controller is being loaded and that causes cells to have inconsistent sizes.
        //So I needed to trigger layout functions of the views after the final change of view frame
        frameObserver.startListening(self,
                                     source: \.view?.frame
        ) { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadData()
            self.mainGrid.frame = self.view.frame.inset(by: view.safeAreaInsets)
            setupScrollView()
        }
    }
    
    func setupScrollView() {
        filterScrollView.addSubview(filterSelector)
        let size = filterSelector.sizeThatFits(.init(width: 0,
                                                     height: view.bounds.size.height))
        let frame = CGRect(x: 0, y: 0,
                           width: size.width,
                           height: 34)
        filterSelector.frame = frame
        filterScrollView.contentSize = frame.size
        filterSelector.delegate = self
    }
    
    func setupTableView() {
        
        tableView.register(DetailCell.self,
                           forCellReuseIdentifier: DetailCell.reuseIdentifier)
        tableView.register(SynonymCell.self,
                           forCellReuseIdentifier: SynonymCell.reuseIdentifier)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tableView.dataSource = self
    }
}

extension WordDetailViewController: WordDetailViewModelDelegate {
    func synonymFetchSuccess() {
        isFooterAvailable = true
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func synonymFetchError(error: Error) {
        isFooterAvailable = false
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func soundFetchSuccess() {
        soundImageView.isHidden = false
    }
    
    func soundFetchError() {
        soundImageView.isHidden = true
    }
}


extension WordDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.meaningsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.definitionsCount(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < (viewModel.isSynonymAvailable ? viewModel.meaningsCount - 1 : viewModel.meaningsCount) {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailCell.reuseIdentifier,
                for: indexPath
            ) as? DetailCell
            else { fatalError("Failed to retreive detail cell.") }
            
            
            guard let dataModel = viewModel.getDetailCellModel(
                section: indexPath.section,
                row: indexPath.row
            ) else { fatalError("Failed to find data at indexPath: \(indexPath)") }
            
            cell.configure(with: dataModel)
            cell.selectionStyle = .none
            
            return cell
        } else  {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SynonymCell.reuseIdentifier,
                for: indexPath
            ) as? SynonymCell
            else { fatalError("Failed to retreive Synonym Cell") }
            
            let model = viewModel.getSynonymCellModel()
            
            cell.configure(with: model)
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            return cell
        }
    }
}

extension WordDetailViewController: SynonymCellDelegate {
    func onCellTapped(_ text: String) {
        self.viewModel.queryForWord(text)
    }
}

extension WordDetailViewController: FilterSelectorDelegate {
    func onFilterRemoved(_ filter: String) {
        viewModel.filterStrings.removeAll { $0 == filter }
        tableView.reloadData()
    }
    
    func onFilterSelected(_ filter: String) {
        viewModel.filterStrings.append(filter)
        tableView.reloadData()
    }
    
    func onFilterClear() {
        viewModel.filterStrings = []
        tableView.reloadData()
    }
    
    
}
