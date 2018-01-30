//
//  FluidCollectionViewLayout.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 26/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

// Based in the implementation by Paride Broggi

import UIKit

public protocol FluidLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

public class FluidCollectionViewLayout: UICollectionViewLayout {
    
    // Config parameters
    var delegate: FluidLayoutDelegate!
    var numberOfColumns: Int = 2
    var cellPadding: CGFloat = 5.0

    /// Setting this value gives a preference for the first column
    /// up to a difference of a number of points
    var ignoreHeightDifferenceBy: CGFloat = 5
    
    var cellWidth: CGFloat {
        if let collectionView = collectionView {
            return (collectionView.bounds.size.width / CGFloat(numberOfColumns)) - (cellPadding * 2)
        }
        return 0
    }
    
    var cachedWidth: CGFloat = 0.0
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat  = 0.0
    
    fileprivate var contentWidth: CGFloat {
        if let collectionView = collectionView {
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
        return 0
    }
    
    fileprivate var numberOfItems = 0
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func prepare() {
        guard let collectionView = collectionView else { return }
        
        guard collectionView.numberOfSections > 0 else {
            //let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
            return
        }
        
        // Is there any spacing between them?
        let totalSpaceWidth = contentWidth - CGFloat(numberOfColumns) * cellWidth
        let horizontalPadding = totalSpaceWidth / CGFloat(numberOfColumns + 1)
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        // Invalidate layout if the cache became invalid
        if (contentWidth != cachedWidth || self.numberOfItems != numberOfItems) {
            cache = []
            contentHeight = 0
            self.numberOfItems = numberOfItems
        }
        
        // Is cache invalid?
        if cache.isEmpty {
            cachedWidth = contentWidth
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * cellWidth + CGFloat(column + 1) * horizontalPadding)
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            for row in 0 ..< numberOfItems {
                
                let indexPath = IndexPath(row: row, section: 0)
                
                let cellHeight = delegate.collectionView(collectionView: collectionView, heightForCellAtIndexPath: indexPath, width: cellWidth)
                let height = cellPadding +  cellHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: height)
                let insetFrame = frame.insetBy(dx: 0, dy: cellPadding)
                
                // Current cell layout attributes
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
                attributes.frame = insetFrame
                cache.append(attributes) // Cache it
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                // Check in which column the next cell should be put
                var nextColumn = (index: 0, height: CGFloat(yOffset[0]))
                
                for columnIndex in 0 ..< numberOfColumns {
                    if yOffset[columnIndex] + ignoreHeightDifferenceBy < nextColumn.height {
                        nextColumn.index = columnIndex
                        nextColumn.height = yOffset[columnIndex]
                    }
                }
                
                column = nextColumn.index
            }
        }
    }
    
    override public func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
//        if layoutAttributes.isEmpty {
//            let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//            let insetFrame = frame.insetBy(dx: 0, dy: 0)
//
//        }
        
        return layoutAttributes
    }
}
