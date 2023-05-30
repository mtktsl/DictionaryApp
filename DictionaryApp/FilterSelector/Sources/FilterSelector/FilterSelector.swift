//
//  HorizontalStackSelector.swift
//  DictionaryApp
//
//  Created by Metin Tarık Kiki on 28.05.2023.
//

import UIKit
import GridLayout

public class FilterSelector: UIView {
    
    //-------------------------------- Definitions --------------------------------
    public weak var delegate: FilterSelectorDelegate?
    
    public private(set) var cancelImage: UIImage?
    public private(set) var font: UIFont = .boldSystemFont(ofSize: 14)
    public private(set) var itemSpacing: CGFloat = 10
    public private(set) var borderColor: UIColor = .black
    public private(set) var borderSelectionColor: UIColor = .blue
    public private(set) var itemBackgroundColor: UIColor = .white
    private var cancelButtonConstraint: NSLayoutConstraint?
    
    public var filters = [String]() {
        didSet {
            setupStackView()
        }
    }
    
    public private(set) var selectedFilters = Set<String>() {
        didSet {
            onFilterChange(
                isEmpty: selectedFilters.isEmpty
            )
        }
    }
    
    lazy var cancelButton: UIView = {
        let imageView = UIImageView(
            image: cancelImage
        )
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        
        let wrapperGrid = Grid.horizontal {
            Star(value: 1, margin: .init(top: 5,
                                         left: 5,
                                         bottom: 5,
                                         right: 5)) {
                imageView
            }
        }
        
        wrapperGrid.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(onCancelButtonTapped(_:)))
        )
        
        wrapperGrid.layer.borderWidth = 1
        wrapperGrid.layer.borderColor = borderSelectionColor.cgColor
        wrapperGrid.isHidden = true
        return wrapperGrid
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    let scrollView = UIScrollView()
    
//-------------------------------- Implementations --------------------------------
    public init(filters: [String] = [],
                cancelImage: UIImage?,
                itemSpacing: CGFloat = 10,
                font: UIFont = .boldSystemFont(ofSize: 14),
                borderColor: UIColor = .black,
                borderSelectionColor: UIColor = .systemBlue,
                itemBackgroundColor: UIColor = .white
    ) {
        super.init(frame: .zero)
        
        self.font = font
        self.borderColor = borderColor
        self.borderSelectionColor = borderSelectionColor
        self.itemBackgroundColor = itemBackgroundColor
        self.cancelImage = cancelImage
        self.filters = makeFiltersUnique(filters)
        self.itemSpacing = itemSpacing
        
        addSubview(stackView)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var totalWidth = stackView.spacing * CGFloat(stackView.subviews.count - 1)
        var totalHeight: CGFloat = .zero
        
        for view in stackView.arrangedSubviews {
            let calculatedSize = view.sizeThatFits(size)
            totalWidth += calculatedSize.width
            totalHeight = max(totalHeight, calculatedSize.height)
        }
        
        return .init(width: totalWidth,
                     height: totalHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutOptionButtons()
        layoutCancelButton()
    }
    
    private func layoutOptionButtons() {
        for view in stackView.arrangedSubviews {
            view.layer.cornerRadius = self.bounds.size.height / 2
        }
    }
    
    private func layoutCancelButton() {
        cancelButtonConstraint?.isActive = false
        cancelButtonConstraint = cancelButton.widthAnchor.constraint(
            equalToConstant: self.bounds.size.height
        )
        cancelButtonConstraint?.isActive = true
        
        cancelButton.layer.cornerRadius = self.bounds.size.height / 2
    }
    
    private func makeFiltersUnique(_ filters: [String]) -> [String] {
        var set = Set<String>()
        return filters.filter { set.insert($0).inserted }
    }
    
    private func onFilterChange(isEmpty: Bool) {
        if isEmpty {
            delegate?.onFilterClear()
        }
        cancelButton.isHidden = isEmpty
    }
    
    private func createOptionButton(_ text: String, tag: Int) -> UIView {
        
        let label = UILabel()
        label.text = text
        label.font = self.font
        
        let grid = Grid.vertical {
            Star(value: 1,
                 margin: .init(top: 0,
                               left: 20,
                               bottom: 0,
                               right: 20)) {
                label
            }
        }
        
        grid.backgroundColor = itemBackgroundColor
        grid.layer.borderColor = borderColor.cgColor
        grid.layer.borderWidth = 1
        grid.tag = tag
        
        grid.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(onOptionSelected(_:)))
        )
        
        return grid
    }
    
    private func setupStackView() {
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        if filters.isEmpty {
            return
        }
        
        stackView.addArrangedSubview(cancelButton)
        
        for i in 0 ..< filters.count {
            stackView.addArrangedSubview(
                createOptionButton(filters[i], tag: i)
            )
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @objc private func onCancelButtonTapped(_ sender: UIButton) {
        selectedFilters.removeAll()
        for i in 1 ..< stackView.arrangedSubviews.count {
            stackView.arrangedSubviews[i].layer.borderColor = borderColor.cgColor
        }
    }
    
    @objc private func onOptionSelected(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view
        else { return }

        let filter = filters[view.tag]
        
        if !selectedFilters.contains(filter) {
            selectedFilters.insert(filter)
            view.layer.borderColor = borderSelectionColor.cgColor
        } else {
            view.layer.borderColor = borderColor.cgColor
            selectedFilters.remove(filter)
        }
        
        delegate?.onFilterSelected(filter)
    }
}
