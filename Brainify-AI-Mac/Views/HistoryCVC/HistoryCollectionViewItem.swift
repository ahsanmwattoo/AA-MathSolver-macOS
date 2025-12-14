//
//  HistoryCollectionViewItem.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class HistoryCollectionViewItem: NSCollectionViewItem {

    static var identifier = NSUserInterfaceItemIdentifier("HistoryCollectionViewItem")
    
    
    @IBOutlet weak var problemImageView: NSImageView!
    @IBOutlet weak var problemText: NSTextField!
    @IBOutlet weak var SolutionText: NSTextField!
    @IBOutlet weak var dateLabel: NSTextField!
    
    var viewModel = HistoryViewModel()
    weak var delegate: HistoryViewController?
    var math: CDMath? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func updateUI() {
            guard let math = math else { return }
            
            problemText.stringValue = math.problemText ?? "Math Problem"
            
            if let imageData = math.problemImage, let image = NSImage(data: imageData) {
                problemImageView.image = image
                problemText.isHidden = true
                problemImageView.isHidden = false
            } else {
                problemImageView.image = nil
                problemText.isHidden = false
                problemImageView.isHidden = true
            }
            
        guard let date = math.date else {
                dateLabel.stringValue = ""
                return
            }
            
            let dayPart = date.relativeDayString()
            let timePart = date.timeString()
            
            dateLabel.stringValue = "\(dayPart), \(timePart)"
        SolutionText.stringValue = math.solution ?? "No Solution"
        
        }
    
    @IBAction func didTapMenu(_ sender: NSButton) {
        let menu = NSMenu()
        let shareItem = NSMenuItem(title: "Share".localized(), action: #selector(shareAction), keyEquivalent: "")
        shareItem.target = self
        
        let deleteItem = NSMenuItem(title: "Delete".localized(), action: #selector(deleteAction), keyEquivalent: "")
        deleteItem.attributedTitle = NSAttributedString(string: "Delete".localized(), attributes: [.foregroundColor: NSColor.red])
        deleteItem.target = self
        
        menu.items = [shareItem, deleteItem]
        menu.popUp(positioning: nil, at: sender.bounds.origin, in: sender)
        self.view.menu = menu
    }
    
    @objc func shareAction() {
        guard let math = math else { return }
        delegate?.handleShareAction(math: math, from: view)
    }
    
    @objc func deleteAction() {
        guard let math = math else { return }
        delegate?.showDeleteConfirmation(for: math)
    }
}
