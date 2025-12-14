//
//  MathResultViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 12/12/2025.
//

import Cocoa
import Combine
import StoreKit

class MathResultViewController: BaseViewController {

    static var identifier = "MathResultViewController"
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollDownButtonView: NSBox!
    
    private let speakerManager = SpeakerManager()
    private var cancellables: Set<AnyCancellable> = []
    private var currentChat: CDChat?
    private var messages = [Message]()
    private var api: GPTService = .init()
    private var task: (Task<(), Never>)?
    private var parser = ARParser(streaming: false)
    private var isStreaming: Bool = false
    private var userIsDragging: Bool = false
    private var streamTimer: Timer?
    
    private var problemText: String?
    private var problemImage: NSImage?
    private var solutionText: String
    
    init(problemText: String, solutionText: String) {
        self.problemText = problemText
        self.solutionText = solutionText
        self.problemImage = nil
        super.init(nibName: "MathResultViewController", bundle: nil)
    }
    
    init(problemImage: NSImage, solutionText: String) {
        self.problemText = nil
        self.solutionText = solutionText
        self.problemImage = problemImage
        super.init(nibName: "MathResultViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        tableView.reloadData()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAutomaticRowHeights = true
        tableView.intercellSpacing = NSSize(width: 0, height: 20)
        
        let assistantResultNib = NSNib(nibNamed: NSNib.Name("AssistantResultTableCellView"), bundle: nil)
        tableView.register(assistantResultNib, forIdentifier: AssistantResultTableCellView.identifier)
        let userResultNib = NSNib(nibNamed: NSNib.Name("AIMathResultProblemCellView"), bundle: nil)
        tableView.register(userResultNib, forIdentifier: AIMathResultProblemCellView.identifier)
    }
    
    @IBAction func didTapBack(_ sender: NSButton) {
        removeChildFromNavigation()
    }
}

extension MathResultViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == 0 {
            guard let cell = tableView.makeView(withIdentifier: AIMathResultProblemCellView.identifier, owner: nil) as? AIMathResultProblemCellView else {
                fatalError()
            }
            
            if let problemText {
                cell.configure(with: problemText)
            } else if let problemImage {
                cell.configure(with: problemImage)
            }
            
            return cell
        } else {
            guard let cell = tableView.makeView(withIdentifier: AssistantResultTableCellView.identifier, owner: nil) as? AssistantResultTableCellView else {
                fatalError()
            }
            
            cell.row = row
            cell.delegate = self
            cell.configure(with: solutionText)
            return cell
        }
    }
}

extension MathResultViewController : TableResultViewCellDelegate {
    func tableCellView(_ cell: NSTableCellView, didTapCopyForRow row: Int) {
        let button = (cell as? AssistantResultTableCellView)?.copyButton
        DispatchQueue.main.async {
            button?.image = .copied
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem.init(block: {
            button?.image = .copychat
        }))
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(solutionText, forType: .string)
    }
    
    func tableCellView(_ cell: NSTableCellView, didTapShareForRow row: Int) {
        let sharingPicker = NSSharingServicePicker.init(items: [solutionText])
        if let button = (cell as? AssistantResultTableCellView)?.shareButton {
            let location = button.convert(view.bounds, to: button)
            sharingPicker.show(relativeTo: location, of: button, preferredEdge: .minY)
        }
    }
    
    func tableCellView(_ cell: NSTableCellView, didTapSpeakForRow row: Int) {
        let button = (cell as? AssistantResultTableCellView)?.playButton
        if speakerManager.isSpeaking {
            DispatchQueue.main.async {
                button?.image = .speak
            }
            if let activeIndex = speakerManager.activeCellIndex,
               activeIndex != row {
                speakerManager.stopSpeaking()
                speakerManager.speak(solutionText, cellIndex: row)
            } else {
                speakerManager.stopSpeaking()
            }
        } else {
            DispatchQueue.main.async {
                button?.image = .speaking
            }
            speakerManager.speak(solutionText, cellIndex: row)
        }
    }
}
