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
                var index: Int { messages.count - 1 }
                createNewChatMessage(text: prompt, role: .user)
                createNewChatMessage(text: "", role: .assistant)
                
                tableView.beginEndUpdates {
                    tableView.insertRows(at: IndexSet(integer: index - 1), withAnimation: .effectFade)
                    tableView.insertRows(at: IndexSet(integer: index), withAnimation: .effectFade)
                }
                
                textView.string.removeAll()
                clearChatBox.isHidden = false
                emptyStackView.isHidden = true
                
                startStreamTimer()
                
                let response = try await api.funcionsCall(text: prompt, model: GPTService.Constants.GPT4o, systemText: """
                                                          You are MathBot, a precise artificial intelligence that exists solely to help with mathematics.

                                                          Core rules:
                                                          - You only provide help for pure mathematics questions (arithmetic, algebra, geometry, trigonometry, calculus, linear algebra, probability, statistics, number theory, discrete math, proofs, etc.).
                                                          - For any message that is clearly NOT a mathematics question (physics, programming, real-world applications, jokes, personal questions, etc.), you must politely decline with a very short reply.
                                                          - Always solve problems accurately and explain step-by-step using proper LaTeX notation.
                                                          - If the question is ambiguous, ask for clarification.

                                                          Special greeting rule (only for simple greetings):
                                                          - If the user’s message is only a greeting such as “Hi”, “Hello”, “Hey”, “Good morning”, etc. (and nothing else), reply kindly with a short greeting and immediately invite a math question.

                                                          Examples of allowed greeting responses:
                                                          User: Hi → You: Hello! How can I help you with mathematics today?
                                                          User: Hey → You: Hey there! Got a math question for me?
                                                          User: Good morning → You: Good morning! Ready to solve some math problems?

                                                          Response when the message is off-topic (not a greeting and not math):
                                                          “I’m sorry, I’m a mathematics-only assistant. I can only help with math questions. Feel free to ask me anything about algebra, calculus, geometry, or any other area of mathematics!”

                                                          You are now ready to receive messages.
""")

                textInputBox.sendButtonState = .canStop
                AppConstants.requestCount += 1
                
                App.incrementFreeAICount()
                if AppConstants.requestCount.isEven, AppConstants.requestCount > 0 {
                    SKStoreReviewController.requestReview()
                }
                
                var currentIndex = response.startIndex // Start index of the response string
                
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
                    
                    let character = response[currentIndex] // Get the character at currentIndex
                    let word = String(character) // Convert character to string
                    streamMessage(word)
                    print("Word: \(word)")
                    
                    currentIndex = response.index(after: currentIndex) // Move to the next character
                }
                
                RunLoop.main.add(timer, forMode: .common)
                
                let timer1 = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] timer in
                    guard let self = self else { return }
                    
                    guard currentIndex < response.endIndex else {
                        timer.invalidate()
                        
                        // Place your bottom code here
                        stopSteamTimer()
                        textInputBox.sendButtonState = .canSend
                        tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 0))
                        return
                    }
                    
                }
                
                RunLoop.main.add(timer1, forMode: .common)
            } catch {
                let message = messages[messages.count - 1]
                stopSteamTimer()
                textInputBox.sendButtonState = .canSend
                
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
        let cell = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? AssistantTableCellView
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            messages[index].content.append(message)
            cell?.stream(messages[index].content)
        }
    }
}

extension AIAssistantsViewController {
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

extension AIAssistantsViewController: TableViewCellDelegate {
    func tableCellView(_ cell: NSTableCellView, didTapSpeakForRow rowIndex: Int) {
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
        let text = messages[rowIndex].content
        let sharingPicker = NSSharingServicePicker.init(items: [text])
        if let button = (cell as? AssistantTableCellView)?.shareButton {
            let location = button.convert(view.bounds, to: button)
            sharingPicker.show(relativeTo: location, of: button, preferredEdge: .minY)
        }
    }
    
    func tableCellView(_ cell: NSTableCellView, didTapCopyForRow rowIndex: Int) {
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
        api.task?.cancel()
        task?.cancel()
    }
}
