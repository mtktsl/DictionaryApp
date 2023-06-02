//
//  DetailCell.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 2.06.2023.
//

import UIKit
import GridLayout

class DetailCell: UITableViewCell {
    
    static let reuseIdentifier = "DetailCell"
    
    
    let numberLabel: UILabel = {
        let numberLabel = UILabel()
        numberLabel.font = .boldSystemFont(ofSize: 18)
        return numberLabel
    }()
    
    let partOfSpeechLabel: UILabel = {
        let partOfSpeechLabel = UILabel()
        partOfSpeechLabel.textColor = .homeButtonColor
        partOfSpeechLabel.font = .systemFont(ofSize: 18).boldItalic
        return partOfSpeechLabel
    }()
    
    let meaningLabel: UILabel = {
        let meaningLabel = UILabel()
        meaningLabel.numberOfLines = 0
        meaningLabel.font = .boldSystemFont(ofSize: 12)
        meaningLabel.setContentHuggingPriority(.defaultHigh,
                                               for: .vertical)
        return meaningLabel
    }()
    
    let exampleTitleLabel: UILabel = {
        let exampleTitleLabel = UILabel()
        exampleTitleLabel.text = "Example"
        exampleTitleLabel.font = .boldSystemFont(ofSize: 12)
        exampleTitleLabel.setContentHuggingPriority(.defaultHigh,
                                                    for: .vertical)
        return exampleTitleLabel
    }()

    let exampleLabel: UILabel = {
        let exampleLabel = UILabel()
        exampleLabel.numberOfLines = 0
        exampleLabel.font = .systemFont(ofSize: 12).boldItalic
        exampleLabel.textColor = .detailExampleColor
        exampleLabel.setContentHuggingPriority(.defaultHigh,
                                               for: .vertical)
        return exampleLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        separatorInset = .zero
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        let topContainer = UIView()
        
        topContainer.addSubview(numberLabel)
        topContainer.addSubview(partOfSpeechLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        partOfSpeechLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: topContainer.topAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            
            partOfSpeechLabel.topAnchor.constraint(equalTo: topContainer.topAnchor),
            partOfSpeechLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor),
            partOfSpeechLabel.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor)
        ])
        
        let mainStackView = UIStackView(
            arrangedSubviews: [
                topContainer,
                meaningLabel,
                exampleTitleLabel,
                exampleLabel
            ]
        )
        
        mainStackView.axis = .vertical
        
        mainStackView.setCustomSpacing(16, after: topContainer)
        mainStackView.setCustomSpacing(16, after: meaningLabel)
        mainStackView.setCustomSpacing(16, after: exampleTitleLabel)
        
        
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(mainStackView, to: contentView, padding: .init(16, 20, 27, 16))
    }
    
    func configure(with model: DetailCellModel) {
        numberLabel.text = "\(model.number) - "
        partOfSpeechLabel.text = model.partOfSpeech
        meaningLabel.text = model.meaning
        
        
        if let exampleText = model.example {
            exampleTitleLabel.isHidden = false
            exampleLabel.isHidden = false
            exampleLabel.text = exampleText
        } else {
            exampleTitleLabel.isHidden = true
            exampleLabel.isHidden  = true
            exampleLabel.text = ""
        }
    }
}
