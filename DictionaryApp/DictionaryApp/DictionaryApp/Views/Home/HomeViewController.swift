//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 28.05.2023.
//

import UIKit
import GridLayout
import KeyboardObserver

class HomeViewController: UIViewController {

    private(set) var searchBar = UIView()
    let searchField = UITextField()
    let recentSearchLabel = UILabel()
    var searchButton = UIButton()
    
    private var windowHeight: CGFloat = 0
    private var isKeyboardOpen = false
    
    lazy var keyboardObserver = KeyboardObserver(self)
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        collectionView.register(RecentSearchCell.self,
                                forCellWithReuseIdentifier: RecentSearchCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    var viewModel: HomeViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    lazy var mainGrid = Grid.vertical {
        Constant(value: 50,
                 margin: .homeSearchBarMargin) {
            searchBar
        }
        Auto(margin: .homeRecentLabelMargin) {
            recentSearchLabel
        }
        Star(value: 1,
             margin: .homeCollectionViewMargin) {
            collectionView
        }
    }
}

// ---------- Function Implementations ------------
extension HomeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchField()
        setupRecentSearchLabel()
        setupSearchButton()
        
        setupMainGrid()
        keyboardObserver.startResizingObserver()
        view.bringSubviewToFront(searchButton)
    }
    
    override func viewDidLayoutSubviews() {
        mainGrid.setNeedsLayout()
        collectionView.reloadData()
    }
    
    private func setupSearchButton() {
        searchButton.setTitle(viewModel.searchButtonTitle,
                              for: .normal)
        searchButton.setTitleColor(.white,
                                   for: .normal)
        searchButton.backgroundColor = .homeButtonColor
        searchButton.addTarget(self,
                               action: #selector(onSearchTap(_:)),
                               for: .touchUpInside)
        searchButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        
        view.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    private func setupRecentSearchLabel() {
        recentSearchLabel.text = viewModel.recentSearchLabelText
        recentSearchLabel.textColor = .homeRecentLabelColor
        recentSearchLabel.font = .boldSystemFont(ofSize: 17)
    }
    
    private func setupSearchField() {
        searchField.placeholder = viewModel.searchFieldPlaceHolder
        searchField.returnKeyType = .default
        searchField.delegate = self
        
        let searchImage = UIImageView(
            image: UIImage(named: viewModel.searchImageName)
        )
        searchImage.contentMode = .scaleAspectFit
        
        let containerGrid = Grid.horizontal {
            Constant(value: 40,
                     margin: .homeSearchImageMargin) {
                searchImage
            }
            Star(value: 1,
                 margin: .homeSearchTextMargin) {
                searchField
            }
        }
        
        containerGrid.layer.cornerRadius = 10
        containerGrid.layer.shadowRadius = 2
        containerGrid.layer.shadowColor = UIColor.lightGray.cgColor
        containerGrid.layer.shadowOffset = .init(width: 0, height: 1)
        containerGrid.layer.shadowOpacity = 0.5
        
        containerGrid.backgroundColor = view.backgroundColor
        
        searchBar = containerGrid
    }
    
    private func setupMainGrid() {
        view.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: searchButton.topAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    @objc func onSearchTap(_ sender: Any) {
        self.view.endEditing(true)
        viewModel.queryForWord(searchField.text ?? "")
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func reloadRecentSearches() {
        collectionView.reloadData()
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentSearchCell.reuseIdentifier,
            for: indexPath) as? RecentSearchCell
        else { fatalError("Unable to cast recentSearchCell") }
        
        let recentSearch = viewModel.getRecentSearch(indexPath.row)
        
        cell.configure(with: .init(
            searchImage: viewModel.searchImageName,
            searchText: recentSearch ?? "...",
            arrowImage: "left-arrow"))
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let recentSearch = viewModel.getRecentSearch(indexPath.row)
        else { return }
        viewModel.queryForWord(recentSearch)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width
        return .init(width: width,
                     height: 40)
    }
}
