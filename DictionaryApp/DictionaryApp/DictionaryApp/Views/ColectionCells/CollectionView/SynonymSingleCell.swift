//
//  SynonymSingleCell.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//

import UIKit

protocol SynonymSingleCellDelegate: AnyObject {
    func onCellTapped(_ text: String)
}

class SynonymSingleCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SynonymSingleCell"
    
    weak var delegate: SynonymSingleCellDelegate?
    
    private var heightConstraint: NSLayoutConstraint? {
        willSet {
            heightConstraint?.isActive = false
            newValue?.priority = .defaultHigh
        }
        didSet {
            heightConstraint?.isActive = true
        }
    }
    private var widthConstraint: NSLayoutConstraint? {
        willSet {
            heightConstraint?.isActive = false
            newValue?.priority = .defaultHigh
        }
        didSet {
            heightConstraint?.isActive = true
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let containerView = UIView()
        containerView.addSubview(label)
        
        contentView.layer.borderColor = UIColor.systemGray3.cgColor
        contentView.layer.borderWidth = 2
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(
            label,
            to: containerView,
            padding: .init(10, 20, 10, 20)
        )
        label.textAlignment = .center
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(containerView, to: contentView)
        
        self.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onCellTapped(_:)))
        )
    }
    
    @objc private func onCellTapped(_ recognizer: UITapGestureRecognizer) {
        guard let text = label.text else { return }
        delegate?.onCellTapped(text)
    }
    
    var didLoadOnce = false
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        
        label.sizeToFit()
        
        attributes.frame.size.height = 33
        if !didLoadOnce {
            attributes.frame.size.width = label.frame.size.width + 40
            didLoadOnce = true
        } else {
            attributes.frame.size.width = (CGFloat(label.text?.count ?? 0)) * 8.35 + 40.0
        }
        return attributes
    }
    
    private func calculateHeight(_ width: CGFloat) -> CGFloat {
        var totalHeight = label.sizeThatFits(.init(width: width, height: 0)).height
        totalHeight += 20
        return totalHeight
    }
    
    func configure(_ text: String,
                   font: UIFont = .boldSystemFont(ofSize: 11)
    ) {
        label.text = text
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.label.font = font
            label.sizeToFit()
            self.contentView.layer.cornerRadius = self.calculateHeight(300) / 2
        }
    }
}
