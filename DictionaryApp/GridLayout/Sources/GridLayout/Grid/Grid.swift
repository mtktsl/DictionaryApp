import UIKit

//
//  Grid.swift
//  GridPanel
//
//  Created by Metin Tarık Kiki on 25.04.2023.
//

import UIKit

public class Grid: UIView {
    
    private var totalGridConstants: CGFloat = 0
    private var totalGridStarts: CGFloat = 0
    
    private var starMultiplier: CGFloat {
        let length = (gridType == .column) ? bounds.size.height
                                           : bounds.size.width
        if length > 0 {
            if totalGridConstants > 0 {
                return (length - totalGridConstants) / length
            }
            return 1
        }
        return 0
    }
    
    private var gridType: GridType = .column
    private var cells = [GridCell]()
    
    //We don't want the grid to be initialized as empty from outside of the class
    private init() {
        super.init(frame: .zero)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func horizontal(@GridBuilder content: () -> [GridLength]) -> Grid {
        return build(cells: content(), gridType: .row)
    }
    
    public static func vertical(@GridBuilder content: () -> [GridLength]) -> Grid {
        return build(cells: content(), gridType: .column)
    }
    
    private static func build(cells: [GridLength], gridType: GridType) -> Grid {
        let grid = Grid()
        grid.gridType = gridType
        grid.setCells(gridLengths: cells)
        grid.calculateTotalStars()
        return grid
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    func updateView() {
        calculateTotalConstants()
        resetSizeConstraints()
        
        for cell in cells {
            setSizeAnchor(cell: cell)
        }
        
        layoutCellsOrthogonally()
        
        layoutCells()
        layoutFirstCell()
        
        updateInnerGrids()
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for cell in cells {
            switch cell.gridLength {
            case .constant(let value, let view, _, _, _):
                
                let calculatedWidth = view.sizeThatFits(
                    CGSize(width: 0,
                           height: self.bounds.size.height)).width
                let calculatedHeight = view.sizeThatFits(
                    CGSize(width: self.bounds.size.width,
                           height: 0)).height
                
                if gridType == .column {
                    totalHeight += value
                    totalWidth = max(totalWidth, calculatedWidth)
                } else {
                    totalWidth += value
                    totalHeight = max(totalHeight, calculatedHeight)
                }
                
            case .expanded(_, let view, _, _, let margin):
                let size = calculateAutoCellSize(view: view,
                                                 maxSize: 0,
                                                 margin: margin)
                
                if gridType == .column {
                    totalWidth = max(totalWidth, size.width)
                    totalHeight += size.height
                } else {
                    totalHeight = max(totalHeight, size.height)
                    totalWidth += size.width
                }
                
            case .auto(let view, _, _, let maxSize, let margin):
                if view.isHidden {
                    continue
                }
                let size = calculateAutoCellSize(view: view,
                                                 maxSize: maxSize,
                                                 margin: margin)
                
                if gridType == .column {
                    totalWidth = max(totalWidth, size.width)
                    totalHeight += size.height
                } else {
                    totalHeight = max(totalHeight, size.height)
                    totalWidth += size.width
                }
                
            }
        }
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    private func calculateAutoCellSize(view: UIView,
                                       maxSize: CGFloat,
                                       margin: UIEdgeInsets) -> CGSize {
        let label = view as? UILabel
        let grid = view as? Grid
        let imageView = view as? UIImageView
        let stackView = view as? UIStackView
        
        if label == nil && grid == nil && imageView == nil && stackView == nil {
            return .zero
        }
        
        var edgeWidth = self.bounds.size.width + margin.left + margin.right
        var edgeHeight = self.bounds.size.height + margin.top + margin.bottom
        
        if maxSize > 0 {
            if gridType == .column && maxSize < edgeHeight {
                edgeHeight = maxSize
            } else if gridType == .row && maxSize < edgeWidth{
                edgeWidth = maxSize
            }
        }
        
        var calculatedWidth = view.sizeThatFits(CGSize(width: 0, height: edgeHeight)).width
        calculatedWidth += margin.left + margin.right
        
        var calculatedHeight = view.sizeThatFits(CGSize(width: edgeWidth, height: 0)).height
        calculatedHeight += margin.top + margin.bottom
        
        return .init(width: calculatedWidth,
                     height: calculatedHeight)
    }
    
    private func setCells(gridLengths: [GridLength]) {
        for length in gridLengths {
            switch length {
            case .constant(let value,
                           let view,
                           let horizontalAlignment,
                           let verticalAlignment,
                           let margin):
                cells.append(GridCell(value: value,
                                      view: view,
                                      gridLength: length,
                                      horizontalAlignment: horizontalAlignment,
                                      verticalAlignment: verticalAlignment,
                                      margin: margin))
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
            case .expanded(let value,
                       let view,
                       let horizontalAlignment,
                       let verticalAlignment,
                       let margin):
                cells.append(GridCell(value: value,
                                      view: view,
                                      gridLength: length,
                                      horizontalAlignment: horizontalAlignment,
                                      verticalAlignment: verticalAlignment,
                                      margin: margin))
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
            case .auto(let view,
                       let horizontalAlignment,
                       let verticalAlignment,
                       _,
                       let margin):
                cells.append(GridCell(value: 0,
                                      view: view,
                                      gridLength: length,
                                      horizontalAlignment: horizontalAlignment,
                                      verticalAlignment: verticalAlignment,
                                      margin: margin))
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
            }
        }
    }
    
    private func calculateTotalStars() {
        totalGridStarts = 0
        for cell in cells {
            switch cell.gridLength {
            case .expanded(let value, _, _, _, _):
                totalGridStarts += value
            default:
                break
            }
        }
    }
    
    private func calculateTotalConstants() {
        totalGridConstants = 0
        for cell in cells {
            if cell.view.isHidden { continue }
            switch cell.gridLength {
            case .constant(let value, _, _, _, _):
                totalGridConstants += value
                
                //Note: Change this the way that it wouldn't be bigger than grid's own frame
            case .auto(let view, _, _, let maxSize, let margin):
                let calculatedSize = (gridType == .column) ?
                CGSize(width: self.bounds.size.width - (margin.left + margin.right),
                       height: 0)
                : CGSize(width: 0,
                         height: self.bounds.size.height - (margin.top + margin.bottom))
                
                let sizeThatFits = view.sizeThatFits(calculatedSize)
                
                let value = (gridType == .column) ? sizeThatFits.height
                                                  : sizeThatFits.width
                
                cell.value = (maxSize > 0 && maxSize < value) ? maxSize : value
                
                totalGridConstants += cell.value
                totalGridConstants += (gridType == .column)
                ? margin.top + margin.bottom
                : margin.left + margin.right
                
            default:
                break
            }
        }
    }
    
    private func resetSizeConstraints() {
        for cell in cells {
            for constraint in cell.constraints {
                constraint.isActive = false
            }
            cell.constraints.removeAll()
        }
    }
    
    private func setSizeAnchor(cell: GridCell) {
        switch cell.gridLength {
        case .constant(_, _, _, _, _):
            if gridType == .column {
                var height = cell.value - (cell.margin.top + cell.margin.bottom)
                
                height = calculateVerticalSpacing(cell: cell, size: height)
                
                let constraint = cell.view.heightAnchor.constraint(equalToConstant: height)
                cell.constraints.append(constraint)
                constraint.isActive = true
            } else {
                var width = cell.value - (cell.margin.left + cell.margin.right)
                
                width = calculateHorizontalSpacing(cell: cell, size: width)
                
                let constraint = cell.view.widthAnchor.constraint(equalToConstant: width)
                cell.constraints.append(constraint)
                constraint.isActive = true
            }
            
        case .expanded(_, _, _, _, _):
            
            if gridType == .column {
                var height = self.bounds.size.height * (cell.value / totalGridStarts) * starMultiplier
                height -= (cell.margin.top + cell.margin.bottom)
                
                height = calculateVerticalSpacing(cell: cell, size: height)
                
                let constraint = cell.view.heightAnchor.constraint(equalToConstant: height)
                cell.constraints.append(constraint)
                constraint.isActive = true
            } else {
                var width = self.bounds.size.width * (cell.value / totalGridStarts) * starMultiplier
                width -= (cell.margin.left + cell.margin.right)
                
                width = calculateHorizontalSpacing(cell: cell, size: width)
                
                let constraint = cell.view.widthAnchor.constraint(equalToConstant: width)
                cell.constraints.append(constraint)
                constraint.isActive = true
            }
        case .auto(_, _, _, let maxSize, _):
            if gridType == .column {
                let limit = self.bounds.size.height - cell.margin.top - cell.margin.bottom
                var height = (cell.value > limit) ? limit : cell.value
                height = (maxSize > 0 && maxSize < height) ? maxSize : height
                
                if cell.view.isHidden {
                    height = .zero
                } else {
                    height = calculateVerticalSpacing(cell: cell, size: height)
                }
                
                let constraint = cell.view.heightAnchor.constraint(equalToConstant: height)
                cell.constraints.append(constraint)
                constraint.isActive = true
            } else {
                let limit = self.bounds.size.width - cell.margin.right - cell.margin.left
                var width = (cell.value > limit) ? limit : cell.value
                width = (maxSize > 0 && maxSize < width) ? maxSize : width
                
                if cell.view.isHidden {
                    width = .zero
                } else {
                    width = calculateHorizontalSpacing(cell: cell, size: width)
                }
                
                let constraint = cell.view.widthAnchor.constraint(equalToConstant: width)
                cell.constraints.append(constraint)
                constraint.isActive = true
            }
        }
    }
    
    private func layoutCells() {
        for i in 1 ..< cells.count {
            layoutArrangedCell(source: cells[i], target: cells[i-1])
        }
    }
    
    private func updateInnerGrids() {
        for cell in cells {
            let grid = cell.view as? Grid
            grid?.updateView()
        }
    }
    
    private func layoutFirstCell() {
        if gridType == .column {
            let topConstant = cells[0].margin.top + cells[0].spacing.top
            let constraint = cells[0].view.topAnchor.constraint(equalTo: self.topAnchor, constant: topConstant)
            cells[0].constraints.append(constraint)
            constraint.isActive = true
        } else {
            let leftConstant = cells[0].margin.left + cells[0].spacing.left
            let constraint = cells[0].view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftConstant)
            cells[0].constraints.append(constraint)
            constraint.isActive = true
        }
    }
    
    private func layoutCellsOrthogonally() {
        for i in 0 ..< cells.count {
            if gridType == .column {
                switch cells[i].horizontalAlignment {
                case .fill:
                    let leftConstraint = cells[i].view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: cells[i].margin.left)
                    let rightConstraint = cells[i].view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -cells[i].margin.right)
                    cells[i].constraints.append(leftConstraint)
                    cells[i].constraints.append(rightConstraint)
                    leftConstraint.isActive = true
                    rightConstraint.isActive = true
                    
                case .constantLeft(let width):
                    let widthConstraint = cells[i].view.widthAnchor.constraint(equalToConstant: width)
                    let leftConstraint = cells[i].view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: cells[i].margin.left)
                    
                    cells[i].constraints.append(widthConstraint)
                    cells[i].constraints.append(leftConstraint)
                    
                    widthConstraint.isActive = true
                    leftConstraint.isActive = true
                    
                case .constantRight(let width):
                    let widthConstraint = cells[i].view.widthAnchor.constraint(equalToConstant: width)
                    let rightConstraint = cells[i].view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -cells[i].margin.right)
                    
                    cells[i].constraints.append(widthConstraint)
                    cells[i].constraints.append(rightConstraint)
                    
                    rightConstraint.isActive = true
                    widthConstraint.isActive = true
                
                case .autoLeft:
                    let width = cells[i].view.sizeThatFits(CGSize(width: 0, height: cells[i].view.bounds.size.height)).width
                    
                    var marginWidth = self.bounds.size.width - cells[i].margin.left - cells[i].margin.right
                    if marginWidth < 0 {
                        marginWidth = 0
                    }
                    
                    let widthConstraint = cells[i].view.widthAnchor.constraint(equalToConstant: width > marginWidth ? marginWidth : width)
                    let leftConstraint = cells[i].view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: cells[i].margin.left)
                    
                    cells[i].constraints.append(widthConstraint)
                    cells[i].constraints.append(leftConstraint)
                    
                    widthConstraint.isActive = true
                    leftConstraint.isActive = true
                    
                case .autoRight:
                    
                    let width = cells[i].view.sizeThatFits(CGSize(width: 0, height: cells[i].view.bounds.size.height)).width
                    
                    var marginWidth = self.bounds.size.width - cells[i].margin.left - cells[i].margin.right
                    if marginWidth < 0 {
                        marginWidth = 0
                    }
                    let widthConstraint = cells[i].view.widthAnchor.constraint(equalToConstant: width > marginWidth ? marginWidth : width)
                    let rightConstraint = cells[i].view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -cells[i].margin.right)
                    
                    cells[i].constraints.append(widthConstraint)
                    cells[i].constraints.append(rightConstraint)
                    
                    rightConstraint.isActive = true
                    widthConstraint.isActive = true
                }
            } else {
                switch cells[i].verticalAlignment {
                case .fill:
                    let topConstraint = cells[i].view.topAnchor.constraint(equalTo: self.topAnchor, constant: cells[i].margin.top)
                    let bottomConstraint = cells[i].view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -cells[i].margin.bottom)
                    
                    cells[i].constraints.append(topConstraint)
                    cells[i].constraints.append(bottomConstraint)
                    
                    topConstraint.isActive = true
                    bottomConstraint.isActive = true
                    
                case .constantTop(let height):
                    let topConstraint = cells[i].view.topAnchor.constraint(equalTo: self.topAnchor, constant: cells[i].margin.top)
                    let heightConstraint = cells[i].view.heightAnchor.constraint(equalToConstant: height)
                    
                    cells[i].constraints.append(topConstraint)
                    cells[i].constraints.append(heightConstraint)
                    
                    topConstraint.isActive = true
                    heightConstraint.isActive = true
                    
                case .constantBottom(let height):
                    let bottomConstraint = cells[i].view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -cells[i].margin.bottom)
                    let heightConstraint = cells[i].view.heightAnchor.constraint(equalToConstant: height)
                    
                    cells[i].constraints.append(bottomConstraint)
                    cells[i].constraints.append(heightConstraint)
                    
                    bottomConstraint.isActive = true
                    heightConstraint.isActive = true
                    
                case .autoTop:
                    let height = cells[i].view.sizeThatFits(CGSize(width: cells[i].view.bounds.size.width, height: 0)).height
                    let topConstraint = cells[i].view.topAnchor.constraint(equalTo: self.topAnchor, constant: cells[i].margin.top)
                    
                    var marginHeight = self.bounds.size.height - cells[i].margin.top - cells[i].margin.bottom
                    if marginHeight < 0 {
                        marginHeight = 0
                    }
                    
                    let heightConstraint = cells[i].view.heightAnchor.constraint(equalToConstant: height > marginHeight ? marginHeight : height)
                    
                    cells[i].constraints.append(topConstraint)
                    cells[i].constraints.append(heightConstraint)
                    
                    topConstraint.isActive = true
                    heightConstraint.isActive = true
                    
                case .autoBottom:
                    let height = cells[i].view.sizeThatFits(CGSize(width: cells[i].view.bounds.size.width, height: 0)).height

                    let bottomConstraint = cells[i].view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -cells[i].margin.bottom)
                    
                    var marginHeight = self.bounds.size.height - cells[i].margin.top - cells[i].margin.bottom
                    if marginHeight < 0 {
                        marginHeight = 0
                    }
                    
                    let heightConstraint = cells[i].view.heightAnchor.constraint(equalToConstant: height > marginHeight ? marginHeight : height)
                    
                    cells[i].constraints.append(bottomConstraint)
                    cells[i].constraints.append(heightConstraint)
                    
                    bottomConstraint.isActive = true
                    heightConstraint.isActive = true
                }
            }
        }
    }
    
    private func layoutArrangedCell(source: GridCell, target: GridCell) {
        if gridType == .column {
            
            var topConstant = source.margin.top + source.spacing.top
            
            switch target.gridLength {
            case .auto(_, _, _, _, _):
                if target.view.isHidden {
                    topConstant -= target.margin.top
                }
            default:
                topConstant += target.margin.bottom + target.spacing.bottom
            }
            
            let constraint = source.view.topAnchor.constraint(equalTo: target.view.bottomAnchor, constant: topConstant)
            source.constraints.append(constraint)
            constraint.isActive = true
            
        } else {
            var leftConstant = source.margin.left + source.spacing.left
            
            switch target.gridLength {
            case .auto(_, _, _, _, _):
                if target.view.isHidden {
                    leftConstant -= target.margin.left
                }
            default:
                leftConstant += target.margin.right + target.spacing.right
            }
            
            let constraint = source.view.leadingAnchor.constraint(equalTo: target.view.trailingAnchor, constant: leftConstant)
            source.constraints.append(constraint)
            constraint.isActive = true
        }
    }
    
    private func calculateVerticalSpacing(cell: GridCell, size: CGFloat) -> CGFloat {
        //if cell.view.isHidden { return .zero }
        switch cell.verticalAlignment {
        case .constantTop(let h):
            let diff = (h > size) ? 0 : size - h
            cell.spacing.bottom = diff
            return h
        case .constantBottom(let h):
            let diff = (h > size) ? 0 : size - h
            cell.spacing.top = diff
            return h
        case .autoTop:
            let fitHeight = cell.view.sizeThatFits(CGSize(width: cell.view.bounds.size.width, height: 0)).height
            let diff = (fitHeight > size) ? 0 : size - fitHeight
            cell.spacing.bottom = diff
            return fitHeight > size ? size : fitHeight
        case .autoBottom:
            let fitHeight = cell.view.sizeThatFits(CGSize(width: cell.view.bounds.size.width, height: 0)).height
            let diff = (fitHeight > size) ? 0 : size - fitHeight
            cell.spacing.top = diff
            return fitHeight > size ? size : fitHeight
        case .fill:
            return size < 0 ? 0 : size
        }
    }
    
    private func calculateHorizontalSpacing(cell: GridCell, size: CGFloat) -> CGFloat {
        //if cell.view.isHidden { return .zero }
        switch cell.horizontalAlignment {
        case .constantLeft(let w):
            let diff = (w > size) ? 0 : size - w
            cell.spacing.right = diff
            return w
        case .constantRight(let w):
            let diff = (w > size) ? 0 : size - w
            cell.spacing.left = diff
            return w
        case .autoLeft:
            let fitWidth = cell.view.sizeThatFits(CGSize(width: 0, height: cell.view.bounds.size.height)).width
            let diff = (fitWidth > size) ? 0 : size - fitWidth
            cell.spacing.right = diff
            return fitWidth > size ? size : fitWidth
        case .autoRight:
            let fitWidth = cell.view.sizeThatFits(CGSize(width: 0, height: cell.view.bounds.size.height)).width
            let diff = (fitWidth > size) ? 0 : size - fitWidth
            cell.spacing.left = diff
            return fitWidth > size ? size : fitWidth
        case .fill:
            return size < 0 ? 0 : size
        }
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return sizeThatFits(targetSize)
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return sizeThatFits(targetSize)
    }
}
