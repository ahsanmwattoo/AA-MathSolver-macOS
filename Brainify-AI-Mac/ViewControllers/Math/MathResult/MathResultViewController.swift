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

    
    @IBAction func didTapBack(_ sender: Any) {
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

extension MathResultViewController {
    @discardableResult
    func createNewChatMessage(text: String, role: Role) -> Message {
        let message = Message(role: role.rawValue, content: text)
        messages.append(message)
        return message
    }
    
    func sendMessage(prompt: String) {
        guard App.canSendQuery else {
            showPremiumScreen()
            return
        }
        task = Task {
            do {
                api.replaceHistory(with: messages)
                var index: Int { messages.count - 1 }
                createNewChatMessage(text: prompt, role: .user)
                createNewChatMessage(text: "", role: .assistant)
                
                tableView.beginEndUpdates {
                    tableView.insertRows(at: IndexSet(integer: index - 1), withAnimation: .effectFade)
                    tableView.insertRows(at: IndexSet(integer: index), withAnimation: .effectFade)
                }
                startStreamTimer()
                
                let response = try await api.funcionsCall(text: prompt, model: GPTService.Constants.GPT4o)

                AppConstants.requestCount += 1
                
                App.incrementFreeCount()
                if AppConstants.requestCount.isEven, AppConstants.requestCount > 0 {
                    SKStoreReviewController.requestReview()
                }
                
                var currentIndex = response.startIndex
                
                let timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] timer in
                    guard let self = self else { return }
                    
                    guard currentIndex < response.endIndex else {
                        timer.invalidate()
                        return
                    }
                    
                    if task?.isCancelled ?? false {
                        task?.cancel()
                        timer.invalidate()
                    }
                    
                    let character = response[currentIndex]
                    let word = String(character)
                    streamMessage(word)
                    
                    currentIndex = response.index(after: currentIndex)
                }
                
                RunLoop.main.add(timer, forMode: .common)
                
                let timer1 = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] timer in
                    guard let self = self else { return }
                    
                    guard currentIndex < response.endIndex else {
                        timer.invalidate()
                        
                        stopSteamTimer()
                        tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 0))
                        return
                    }
                    
                }
                
                RunLoop.main.add(timer1, forMode: .common)
            } catch {
                let message = messages[messages.count - 1]
                stopSteamTimer()
                
                if !messages.isEmpty {
                    if message.content.isEmpty {
                        messages[messages.count - 1] = Message(role: Role.assistant.rawValue, content: "Failed to connect to server. Please check your internet connection.".localized())
                        tableView.reloadData()
                    } else {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func streamMessage(_ message: String) {
        let index = messages.count - 1
        guard index >= 0 else { return }
        let cell = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? AssistantResultTableCellView
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            messages[index].content.append(message)
            cell?.stream(messages[index].content)
        }
    }
}

extension MathResultViewController {
    func startStreamTimer() {
        if streamTimer == nil {
            isStreaming = true
            streamTimer = Timer.scheduledTimer(timeInterval: 0.23, target: self, selector: #selector(scrollStream), userInfo: nil, repeats: true)
        }
    }
    
    @objc func scrollStream() {
        if !userIsDragging{
            if isStreaming {
                scrollDownButtonView.isHidden = true
            }else{
                scrollDownButtonView.isHidden = isAtBottom()
            }
        }else{
            scrollDownButtonView.isHidden = isAtBottom()
        }
        if !userIsDragging {
            smoothScrollToBottom()
        }
    }
    
    func stopSteamTimer() {
        if streamTimer != nil {
            isStreaming = false
            self.streamTimer?.invalidate()
            self.streamTimer = nil
        }
    }
    
    @IBAction func onScrollDownClick(_ sender: Any) {
        if isStreaming &&
            messages[messages.count - 1].content.isEmpty &&
            messages[messages.count - 1].reasoningContent?.isEmpty ?? false {
            smoothScrollToBottom()
        } else {
            tableView.scrollToBottom()
            userIsDragging = false
        }
    }
    
    func isAtBottom() -> Bool {
        guard let scrollView = tableView.enclosingScrollView else { return false }
        let contentHeight = scrollView.contentView.bounds.height
        let documentHeight = scrollView.documentView?.bounds.height ?? 0
        let scrollOffsetY = scrollView.contentView.bounds.origin.y
        let distanceFromBottom = documentHeight - scrollOffsetY - contentHeight
        return distanceFromBottom <= 45.0
    }
    
    func smoothScrollToBottom() {
        guard let scrollView = tableView.enclosingScrollView else { return }
        
        let lastRow = tableView.numberOfRows - 1
        guard lastRow >= 0 else { return }
        
        let lastRowRect = tableView.rect(ofRow: lastRow)
        let targetPoint = NSPoint(x: 0, y: lastRowRect.maxY - scrollView.contentView.bounds.height)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            scrollView.contentView.animator().setBoundsOrigin(targetPoint)
        }
    }
}

extension MathResultViewController : InputBoxDelegate {
    func textInputBox(_ box: InputBox, didTapSendWithText text: String) {
        sendMessage(prompt: text)
    }
    
    func textInputBoxDidTapStop(_ box: InputBox) {
        api.task?.cancel()
        task?.cancel()
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
