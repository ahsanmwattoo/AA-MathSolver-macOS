//
//  NSTableView.swift
//  DownTik
//
//  Created by Macbook Pro on 19/05/2025.
//

import Cocoa

extension NSTableView {
    func scrollToBottom() {
        let lastRow = numberOfRows - 1
        if lastRow >= 0 {
            // Get the rect of the last row
            let lastRowRect = rect(ofRow: lastRow)
            // Get the scroll view that contains the table view
            guard let scrollView = enclosingScrollView else { return }
            // Calculate the bottom point of the last row, ensuring it remains visible
            let bottomPoint = NSPoint(x: 0, y: max(0, lastRowRect.origin.y + lastRowRect.size.height - scrollView.contentView.bounds.size.height))
            // Animate the scrolling to the bottom of the last row
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 1 // Duration of the animation
                scrollView.contentView.animator().scroll(to: bottomPoint)
            }, completionHandler: nil)
        }
    }
    
    func reloadDataWithSameContentOffset() {
        let visibleRect = enclosingScrollView?.contentView.bounds ?? .zero
        let currentScrollPoint = visibleRect.origin

        // Reload data
        reloadData()

        // Restore scroll position
        enclosingScrollView?.contentView.scroll(to: currentScrollPoint)
        enclosingScrollView?.reflectScrolledClipView(enclosingScrollView!.contentView)
    }
    
    func reloadVisibleRows() {
        let visibleRect = visibleRect
        let visibleRows = rows(in: visibleRect)
        let visibleIndexSet = IndexSet(integersIn: visibleRows.lowerBound..<visibleRows.upperBound)
        reloadData(forRowIndexes: visibleIndexSet, columnIndexes: IndexSet(integersIn: 0..<numberOfColumns))
    }
    
    func beginEndUpdates(_ updates: () -> Void) {
        beginUpdates()
        updates()
        endUpdates()
    }
}
