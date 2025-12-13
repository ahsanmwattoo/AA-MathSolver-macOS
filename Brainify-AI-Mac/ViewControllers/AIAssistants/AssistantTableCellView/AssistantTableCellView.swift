//
//  AssistantTableCellView.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa
import Markdown
import Lottie

protocol TableViewCellDelegate: AnyObject {
    func tableCellView(_ cell: NSTableCellView, didTapCopyForRow row: Int)
    func tableCellView(_ cell: NSTableCellView, didTapShareForRow row: Int)
    func tableCellView(_ cell: NSTableCellView, didTapSpeakForRow row: Int)
}


class AssistantTableCellView: NSTableCellView {
    
    @IBOutlet weak var streamLabel: NSTextField!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var shareButton: NSButton!
    @IBOutlet weak var processingAnimationView: LottieAnimationView!
    
    
    static let identifier = NSUserInterfaceItemIdentifier("AssistantTableCellView")
    private var parser = ARParser(streaming: true)
    
    var speakerCallback: ((Bool, Int?) -> Void)?
    weak var delegate: TableViewCellDelegate?
    var rowIndex = 0
    var message: Message?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        processingAnimationView.loopMode = .loop
    }
    func configure(with message: Message) {
        let document = Document(parsing: message.content)
        streamLabel.attributedStringValue = parser.attributedString(from: document)
    }
    
    func stream(_ message: String) {
        print("called: streamCalled")
//        streamLabel.isHidden = false
        hideAndStop()
        let document = Document(parsing: message)
        streamLabel.attributedStringValue = parser.attributedString(from: document)
    }
    
    func setupSpeakerCallBack() {
        speakerCallback = { [weak self] isPlaying, index in
            guard let self else { return }
            
            if rowIndex == index && isPlaying {
                playButton.image = .speaking
            } else {
                playButton.image = .speak
            }
        }
    }
    
    func showAndPlay() {
        let animationName = NSApp.effectiveAppearance.isDarkMode ? "chat loader brainify dark" : "chat loader brainify light"
        processingAnimationView.animation = LottieAnimation.named(animationName)
        processingAnimationView.play()
        processingAnimationView.isHidden = false
    }
    
    func hideAndStop() {
        processingAnimationView.stop()
        processingAnimationView.isHidden = true
    }
    
    @IBAction func didTapCopy(_ sender: NSButton) {
        delegate?.tableCellView(self, didTapCopyForRow: rowIndex)
    }
    
    
    @IBAction func didTapPlay(_ sender: NSButton) {
        delegate?.tableCellView(self, didTapSpeakForRow: rowIndex)
    }
    
    @IBAction func didTapShare(_ sender: NSButton) {
        delegate?.tableCellView(self, didTapShareForRow: rowIndex)
    }
}
