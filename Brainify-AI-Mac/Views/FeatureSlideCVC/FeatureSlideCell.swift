//
//  FeatureSlideCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 27/11/2025.
//

import Cocoa

class FeatureSlideCell: NSCollectionViewItem {

    static var identifier = "FeatureSlideCell"
    @IBOutlet weak var featureImage: NSImageView!
    @IBOutlet weak var featureTitle: NSTextField!
    
    func configure(imageName: String, title: String) {
            featureImage.image = NSImage(named: imageName)
            featureTitle.stringValue = title
    }
}
