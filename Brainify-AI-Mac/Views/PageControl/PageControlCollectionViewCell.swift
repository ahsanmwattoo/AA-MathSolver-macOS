//
//  PageControlCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 27/11/2025.
//

import Cocoa

class PageControlCollectionViewCell: NSCollectionViewItem {

    static var identifier = "PageControlCollectionViewCell"
    @IBOutlet weak var dotView: NSView!
    @IBOutlet weak var dotViewWIdth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dotView.wantsLayer = true
        dotView.layer?.cornerRadius = dotView.frame.width / 2
        dotView.layer?.backgroundColor = NSColor.systemPurple.cgColor
            
            // Agar constraint nahi mila to bana do
            if dotViewWIdth == nil {
                let constraint = dotView.widthAnchor.constraint(equalToConstant: 6)
                constraint.isActive = true
                dotViewWIdth = constraint
            }
    }
    
    override var isSelected: Bool {
        didSet {
            dotView.layer?.backgroundColor = isSelected ? NSColor.brand.cgColor : NSColor.stroke.cgColor
            let newWidth: CGFloat = isSelected ? 24 : 6
            let newRadius: CGFloat = isSelected ? 3 : 3
                        
                        // Smooth animation
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.32
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.dotViewWIdth.constant = newWidth
                self.dotView.layer?.cornerRadius = newRadius
                self.view.layoutSubtreeIfNeeded()
            }
        }
    }
}
