//
//  RecentSearchCell.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 30.05.2023.
//

import UIKit
import GridLayout

class RecentSearchCell: UICollectionViewCell {
    static let reuseIdentifier = "RecentSearchCell"
    
    let searchImageView: UIImageView = {
        let searchImageView = UIImageView()
        searchImageView.contentMode = .scaleAspectFit
        return searchImageView
    }()
    
    let textLabel: UILabel = {
        let textLabel = UILabel()
        return textLabel
    }()
    
    let arrowImageView: UIImageView = {
        let arrowImageView = UIImageView()
        arrowImageView.contentMode = .scaleAspectFit
        return arrowImageView
    }()
    
    lazy var mainGrid = Grid.horizontal {
        Constant(value: 50,
                 margin: .recentCellImageMargin) {
            searchImageView
        }
        Star(value: 1,
             margin: .init(0, 10)) {
            textLabel
        }
        Constant(value: 50,
                 margin: .recentCellArrowMargin) {
            arrowImageView
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMainGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMainGrid() {
        contentView.addSubview(mainGrid)
        
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with model: RecentSearchCellModel) {
        searchImageView.image = UIImage(named: model.searchImage)
        textLabel.text = model.searchText
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.arrowImageView.image = UIImage(named: model.arrowImage)?.withHorizontallyFlippedOrientation()
        }
    }
}
