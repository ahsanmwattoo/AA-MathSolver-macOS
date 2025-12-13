//
//  NSCollectionView.swift
//  EmoTalk
//
//  Created by Macbook Pro on 15/10/2025.
//

import Cocoa

extension NSCollectionView {
    func hideScrollers() {
        enclosingScrollView?.verticalScroller?.alphaValue = 0
        enclosingScrollView?.horizontalScroller?.alphaValue = 0
    }
    func selectItem(index: Int, section: Int, scrollPosition: NSCollectionView.ScrollPosition = .left) {
        selectItems(at: [IndexPath(item: index, section: section)], scrollPosition: scrollPosition)
    }
    
    func scrollToTop(animated: Bool) {
        guard let scrollView = enclosingScrollView else { return }
        
        let targetOffset = NSPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height)
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
                context.duration = 1
                scrollView.contentView.animator().setBoundsOrigin(targetOffset)
            }, completionHandler: nil)
        } else {
            scrollView.contentView.setBoundsOrigin(targetOffset)
        }
    }
}

extension NSCollectionView {
    func hideVerticalScroller() {
        enclosingScrollView?.verticalScroller?.alphaValue = 0
    }
    
    func hideHorizontalScroller() {
        enclosingScrollView?.horizontalScroller?.alphaValue = 0
    }
    
    func getNib(name: String) -> NSNib? {
        NSNib(nibNamed: name, bundle: nil)
    }
    
    func reloadWithSelectedIndexPaths() {
        let selectedIndexPaths = selectionIndexPaths
        reloadData()
        selectItems(at: selectedIndexPaths, scrollPosition: .top)
    }
}

extension NSTableView {
    func hideVerticalScroller() {
        enclosingScrollView?.verticalScroller?.alphaValue = 0
    }
    
    func hideHorizontalScroller() {
        enclosingScrollView?.horizontalScroller?.alphaValue = 0
    }
    
    func hideScrollers() {
        hideVerticalScroller()
        hideHorizontalScroller()
    }
}
