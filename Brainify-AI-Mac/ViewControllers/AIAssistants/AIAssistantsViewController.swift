//
//  AIAssistantsViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa
import Combine
import StoreKit

class AIAssistantsViewController: BaseViewController {
    
    static var identifier = "AIAssistantsViewController"
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollDownButtonView: NSBox!
    @IBOutlet weak var emptyStackView: NSImageView!
    @IBOutlet var textView: PlaceHolderTextView!
    @IBOutlet weak var textInputBox: TextInputBox!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var clearChatBox: NSBox!
    @IBOutlet weak var clearChatLabel: NSTextField!
    @IBOutlet weak var titleConstraint: NSLayoutConstraint!
    
    private var streamingTimer: Timer?
    private var completionCheckTimer: Timer?
    private var responseString: String = ""
    private var currentStreamIndex = 0
    private let speakerManager = SpeakerManager()
    private var cancellables: Set<AnyCancellable> = []
    private var currentChat: CDChat?
    private var messages = [Message]()
    private var api: GPTService = GPTService()
    private var task: (Task<(), Never>)?
    private var parser = ARParser(streaming: false)
    private var isStreaming: Bool = false
    private var userIsDragging: Bool = false
    private var streamTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.placeholderString = "Ask anything...".localized()
        textView.font = .systemFont(ofSize: 16)
        configureTableView()
        textInputBox.delegate = self
        titleConstraint?.isActive = false
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        tableView.reloadData()
        
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            textView.placeholderString = "Ask anything...".localized()
            titleLabel.stringValue = "Boost Productivity with Intelligent Math Assistants!".localized()
            clearChatLabel.stringValue = "Clear Chat".localized()
        }
    }
    
    @IBAction func didTapClearChat(_ sender: Any) {
        clearChatBox.isHidden = true
        titleConstraint?.isActive = false
        messages = []
        emptyStackView.isHidden = false
        tableView.reloadData()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAutomaticRowHeights = true
        tableView.intercellSpacing = NSSize(width: 0, height: 20)
        tableView.hideScrollers()
        
        let userMessageNib = NSNib(nibNamed: "UserTableCellView", bundle: nil)
        tableView.register(userMessageNib, forIdentifier: UserTableCellView.identifier)
        
        let assistantMessageNib = NSNib(nibNamed: "AssistantTableCellView", bundle: nil)
        tableView.register(assistantMessageNib, forIdentifier: AssistantTableCellView.identifier)
    }
}

extension AIAssistantsViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let message = messages[row]
        
        if message.role == Role.user.rawValue {
            guard let cell = tableView.makeView(withIdentifier: UserTableCellView.identifier, owner: nil) as? UserTableCellView else {
                fatalError()
            }
            
            cell.configure(with: message)
            return cell
        } else if message.role == Role.assistant.rawValue {
            guard let cell = tableView.makeView(withIdentifier: AssistantTableCellView.identifier, owner: nil) as? AssistantTableCellView else {
                fatalError()
            }
            guard message.content.isNotEmpty else {
                cell.showAndPlay()
                return cell
            }
            
            cell.rowIndex = row
            cell.delegate = self
            cell.configure(with: message)
            cell.hideAndStop()
            return cell
        }
        
        return nil
    }
}

extension AIAssistantsViewController {
    @discardableResult
    func createNewChatMessage(text: String, role: Role) -> Message {
        let message = Message(role: role.rawValue, content: text)
        messages.append(message)
        return message
    }
    
    func sendMessage(prompt: String) {
        task = Task {
            do {
                api.replaceHistory(with: messages)
                let userIndex = messages.count
                createNewChatMessage(text: prompt, role: .user)
                createNewChatMessage(text: "", role: .assistant)
                
                tableView.beginEndUpdates {
                    tableView.insertRows(at: IndexSet(integer: userIndex), withAnimation: .effectFade)
                    tableView.insertRows(at: IndexSet(integer: userIndex + 1), withAnimation: .effectFade)
                }
                
                textView.string = ""
                clearChatBox.isHidden = false
                titleConstraint?.isActive = true
                emptyStackView.isHidden = true
                textInputBox.sendButtonState = .canStop
                startStreamTimer()
                
                let response = try await api.funcionsCall(text: prompt, model: GPTService.Constants.GPT4o, systemText: "You are an expert mathematics assistant. Solve any math problem accurately with clear, step-by-step explanations using proper LaTeX notation. Stay focused only on mathematics.")
                
                await MainActor.run {
                    self.responseString = response
                    self.currentStreamIndex = 0
                    self.startCharacterStreaming()
                }
                
                AppConstants.requestCount += 1
                App.incrementFreeAICount()
                SKStoreReviewController.requestReview()
                
            } catch {
                await MainActor.run {
                    stopAllStreaming()
                    textInputBox.sendButtonState = .canSend
                    
                    let lastIndex = messages.count - 1
                    if lastIndex >= 0 && messages[lastIndex].content.isEmpty {
                        messages[lastIndex].content = "Failed to connect to server. Please check your internet connection.".localized()
                        tableView.reloadData(forRowIndexes: IndexSet(integer: lastIndex), columnIndexes: IndexSet(integer: 0))
                    }
                }
            }
        }
    }

    private func startCharacterStreaming() {
        guard !responseString.isEmpty else {
            stopAllStreaming()
            textInputBox.sendButtonState = .canSend
            return
        }
        
        streamingTimer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            if self.currentStreamIndex >= self.responseString.count {
                timer.invalidate()
                return
            }
            
            let index = self.responseString.index(self.responseString.startIndex, offsetBy: self.currentStreamIndex)
            let char = String(self.responseString[index])
            self.streamMessage(char)
            self.currentStreamIndex += 1
        }
        
        completionCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            if self.currentStreamIndex >= self.responseString.count {
                timer.invalidate()
                self.finalizeStreaming()
            }
        }
    }

    private func finalizeStreaming() {
        stopAllStreaming()
        textInputBox.sendButtonState = .canSend
        
        let lastRow = messages.count - 1
        if lastRow >= 0 {
            tableView.reloadData(forRowIndexes: IndexSet(integer: lastRow), columnIndexes: IndexSet(integer: 0))
        }
    }

    private func stopAllStreaming() {
        streamingTimer?.invalidate()
        streamingTimer = nil
        completionCheckTimer?.invalidate()
        completionCheckTimer = nil
        stopSteamTimer()
        responseString = ""
        currentStreamIndex = 0
    }
    
    func streamMessage(_ message: String) {
        let index = messages.count - 1
        guard index >= 0 else { return }
        let cell = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? AssistantTableCellView
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            messages[index].content.append(message)
            cell?.stream(messages[index].content)
        }
    }
}

extension AIAssistantsViewController {
    
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
    
    func startStreamTimer() {
        guard streamTimer == nil else { return }
        isStreaming = true
        streamTimer = Timer.scheduledTimer(timeInterval: 0.23, target: self, selector: #selector(scrollStream), userInfo: nil, repeats: true)
    }

    func stopSteamTimer() {
        isStreaming = false
        streamTimer?.invalidate()
        streamTimer = nil
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

extension AIAssistantsViewController: TableViewCellDelegate {
    func tableCellView(_ cell: NSTableCellView, didTapSpeakForRow rowIndex: Int) {
        api.task?.cancel()
        task?.cancel()
        let text = messages[rowIndex].content
        let button = (cell as? AssistantTableCellView)?.playButton
        if speakerManager.isSpeaking {
            DispatchQueue.main.async {
                button?.image = .speak
            }
            if let activeIndex = speakerManager.activeCellIndex,
               activeIndex != rowIndex {
                speakerManager.stopSpeaking()
                speakerManager.speak(text, cellIndex: rowIndex)
            } else {
                speakerManager.stopSpeaking()
            }
        } else {
            DispatchQueue.main.async {
                button?.image = .speaking
            }
            speakerManager.speak(text, cellIndex: rowIndex)
        }
    }
    
    func tableCellView(_ cell: NSTableCellView, didTapShareForRow rowIndex: Int) {
        api.task?.cancel()
        task?.cancel()
        let text = messages[rowIndex].content
        let sharingPicker = NSSharingServicePicker.init(items: [text])
        if let button = (cell as? AssistantTableCellView)?.shareButton {
            let location = button.convert(view.bounds, to: button)
            sharingPicker.show(relativeTo: location, of: button, preferredEdge: .minY)
        }
    }
    
    func tableCellView(_ cell: NSTableCellView, didTapCopyForRow rowIndex: Int) {
        api.task?.cancel()
        task?.cancel()
        let text = messages[rowIndex].content
        let button = (cell as? AssistantTableCellView)?.copyButton
        DispatchQueue.main.async {
            button?.image = .copied
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem.init(block: {
            button?.image = .copychat
        }))
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        print("Copied Text: \(text)")
        pasteboard.setString(text, forType: .string)
    }
}


extension AIAssistantsViewController: TextInputBoxDelegate {
    func textInputBox(_ box: TextInputBox, didTapSendWithText text: String) {
        guard App.isPro || App.canSendQuery else {
            // TODO: Show Premium Screen Here
            showPremiumScreen()
            return
        }
        sendMessage(prompt: text)
    }
    
    func textInputBoxDidTapStop(_ box: TextInputBox) {
        task?.cancel()
        api.task?.cancel()
        
        DispatchQueue.main.async {
            self.stopAllStreaming()
            box.sendButtonState = .canSend
            
            let lastIndex = self.messages.count - 1
            if lastIndex >= 0 {
                let cell = self.tableView.view(atColumn: 0, row: lastIndex, makeIfNecessary: true) as? AssistantTableCellView
                cell?.hideAndStop()
                self.tableView.reloadData(forRowIndexes: IndexSet(integer: lastIndex), columnIndexes: IndexSet(integer: 0))
            }
        }
    }
}
