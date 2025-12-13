//
//  GrowingTextScrollView.swift
//  ChatGPTmacAR
//
//  Created by Ahsan Murtaza on 03/09/2025.
//

import Foundation
import Cocoa

class GrowingTextScrollView: NSScrollView {
    
    var maxNumberOfLines: Int = 10 {
        didSet { recalcHeight() }
    }
    
    private var heightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        drawsBackground = false
        hasVerticalScroller = false
        hasHorizontalScroller = false
        
        if let textView = documentView as? NSTextView {
            textView.isVerticallyResizable = true
            textView.isHorizontallyResizable = false
            textView.textContainer?.widthTracksTextView = true
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textDidChange),
                name: NSText.didChangeNotification,
                object: textView
            )
        }
        
        if let hc = constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint = hc
        } else {
            heightConstraint = heightAnchor.constraint(equalToConstant: 35)
            heightConstraint?.isActive = true
        }
    }
    
    @objc private func textDidChange() {
        recalcHeight()
    }
    
    func recalcHeight() {
        guard let textView = documentView as? NSTextView,
              let font = textView.font else { return }
        
        let textHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height ?? 0
        let lineHeight = font.lineHeight + 4
        let maxHeight = lineHeight * CGFloat(maxNumberOfLines) + textView.textContainerInset.height * 2
        
        let finalHeight = min(maxHeight, textHeight + textView.textContainerInset.height * 2)
        heightConstraint?.constant = max(finalHeight, lineHeight + 12) // at least 1 line tall
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NSFont {
    var lineHeight: CGFloat {
        return ascender + abs(descender) + leading
    }
}
