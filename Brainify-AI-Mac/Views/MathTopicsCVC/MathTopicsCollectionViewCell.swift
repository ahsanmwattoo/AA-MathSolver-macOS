//
//  MathTopicsCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//

import Cocoa

class MathTopicsCollectionViewCell: NSCollectionViewItem {

    static var identifier = "MathTopicsCollectionViewCell"
    @IBOutlet weak var imageIcon: NSImageView!
    @IBOutlet weak var topicName: NSTextField!
    @IBOutlet weak var subTitle: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(with topic: MathTopics) {
        imageIcon.image = topic.image
        topicName.stringValue = topic.title.localized()
        subTitle.stringValue = topic.subtitle.localized()
    }
    
//    func configure(with aiassitant: AIAssistants) {
//        topicName.stringValue = aiassitant.title
//        imageIcon.image = aiassitant.icon
//        subTitle.stringValue = aiassitant.subtitle
//    }
}
