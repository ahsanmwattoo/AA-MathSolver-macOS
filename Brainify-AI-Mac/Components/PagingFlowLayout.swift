//
//  PagingFlowLayout.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//

import Cocoa

class PagingFlowLayout: NSCollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect) 
        
        for attribute in attributes {
            attribute.size = collectionView?.bounds.size ?? .zero
        }
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: NSPoint, withScrollingVelocity velocity: NSPoint) -> NSPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let pageWidth = collectionView.bounds.width
        let currentOffset = proposedContentOffset.x
        let targetOffset = round(currentOffset / pageWidth) * pageWidth
        
        return NSPoint(x: targetOffset, y: proposedContentOffset.y)
    }
}
