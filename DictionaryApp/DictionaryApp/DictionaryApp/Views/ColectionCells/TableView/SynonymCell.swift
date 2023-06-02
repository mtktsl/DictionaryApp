//
//  SynonymCell.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 1.06.2023.
//

import UIKit

protocol SynonymCellDelegate: AnyObject {
    func onCellTapped(_ text: String)
}

class SynonymCell: UITableViewCell {
    
    static let reuseIdentifier = "SynonymCell"
    
    weak var delegate: SynonymCellDelegate?
    
    private var heightConstraint: NSLayoutConstraint? {
        willSet {
            heightConstraint?.isActive = false
            newValue?.priority = .defaultHigh
        }
        didSet {
            heightConstraint?.isActive = true
        }
    }
    
    var items = [String]()
    var maxItemNum = 5
    
    var cellFont: UIFont = .boldSystemFont(ofSize: 11)
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.setContentHuggingPriority(
            .defaultHigh,
            for: .vertical
        )
        return titleLabel
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = SynonymCollectionLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.register(
            SynonymSingleCell.self,
            forCellWithReuseIdentifier: SynonymSingleCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    let itemObserver = ChangeObserver()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let containerView = UIView()
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.expand(
            containerView,
            to: contentView,
            padding: .init(16, 20, 27, 16)
        )
    }
    
    private func calculateHeight(_ multiplier: CGFloat = 1) {
        self.heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 165)
    }
    
    func configure(with model: SynonymCellModel) {
        self.items = model.synonyms
        self.maxItemNum = model.maxItemNum
        titleLabel.text = model.title
        calculateHeight()
        collectionView.reloadData()
    }
}

extension SynonymCell {
    override var bounds: CGRect {
        didSet {
            self.collectionView.reloadData()
            self.collectionView.setNeedsLayout()
            self.collectionView.layoutIfNeeded()
        }
    }
}

extension SynonymCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count > maxItemNum ? maxItemNum : items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SynonymSingleCell.reuseIdentifier,
            for: indexPath
        ) as? SynonymSingleCell
        else { fatalError("Failed to retrieve Synonym Single Cell") }
        
        cell.configure(items[indexPath.row])
        cell.delegate = self
        
        return cell
    }
}

extension SynonymCell: SynonymSingleCellDelegate {
    func onCellTapped(_ text: String) {
        delegate?.onCellTapped(text)
    }
}
