//
//  AssistantResultTableCellView.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa
import Markdown
import Lottie

protocol TableResultViewCellDelegate: AnyObject {
    func tableCellView(_ cell: NSTableCellView, didTapCopyForRow row: Int)
    func tableCellView(_ cell: NSTableCellView, didTapShareForRow row: Int)
    func tableCellView(_ cell: NSTableCellView, didTapSpeakForRow row: Int)
}

class AssistantResultTableCellView: NSTableCellView {
    
    static let identifier = NSUserInterfaceItemIdentifier("AssistantResultTableCellView")
    
    @IBOutlet weak var solutionLabel: NSTextField!
    @IBOutlet weak var streamLabel: NSTextField!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var shareButton: NSButton!
    @IBOutlet weak var lottieAnimationView: LottieAnimationView!
    
    private var parser = ARParser(streaming: true)
    weak var delegate: TableResultViewCellDelegate?
    var row: Int = 0
    var speakerCallback: ((Bool, Int?) -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        solutionLabel.stringValue = "Solution".localized()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        solutionLabel.stringValue = "Solution".localized()
        streamLabel.allowsEditingTextAttributes = true
    }
    
    func configure(with message: Message) {
        let document = Document(parsing: message.content)
        streamLabel.attributedStringValue = parser.attributedString(from: document)
    }
    
    func configure(with solution: String) {
        let document = Document(parsing: solution)
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
            
            if row == index && isPlaying {
                playButton.image = .speaking
            } else {
                playButton.image = .speak
            }
        }
    }
    
    func showAndPlay() {
        let animationName = NSApp.effectiveAppearance.isDarkMode ? "chat loader brainify dark" : "chat loader brainify light"
        lottieAnimationView.animation = LottieAnimation.named(animationName)
        lottieAnimationView.play()
        lottieAnimationView.isHidden = false
    }
    
    func hideAndStop() {
        lottieAnimationView.stop()
        lottieAnimationView.isHidden = true
    }

    
    @IBAction func didTapCopy(_ sender: NSButton) {
        delegate?.tableCellView(self, didTapCopyForRow: row)
    }
    
    @IBAction func didTapSpeak(_ sender: Any) {
        delegate?.tableCellView(self, didTapSpeakForRow: row)
    }
    
    @IBAction func didTapShare(_ sender: Any) {
        delegate?.tableCellView(self, didTapShareForRow: row)
    }
}
