//
//  TopicViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 29/11/2025.
//

import Cocoa
import Combine
import StoreKit

class TopicViewController: BaseViewController {

    static var identifier = "TopicViewController"
    @IBOutlet weak var imageIcon: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var emptyStackView: NSBox!
    @IBOutlet weak var textInputBox: InputBox!
    @IBOutlet weak var scrollDownButtonView: NSBox!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var shareButton: NSButton!
    @IBOutlet weak var clearChatBox: NSBox!
    
    var image: NSImage?
    var titleText: String?
    var subtitle: String?
    var placeholder: String?
    var systemText: String?
    
    private var streamingTimer: Timer?
    private var completionCheckTimer: Timer?
    private var responseString: String = ""
    private var currentStreamIndex = 0
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
            titleLabel.stringValue = titleText?.localized() ?? ""
            subtitleLabel.stringValue = subtitle?.localized() ?? ""
            textView.placeholderString = placeholder?.localized() ?? "Write your equation here...".localized()
        }
    }
    
    func setupUI() {
        imageIcon.image = image
        titleLabel.stringValue = titleText ?? ""
        subtitleLabel.stringValue = subtitle ?? ""
        textView.placeholderString = placeholder ?? "Write your equation here...".localized()
        textView.font = .systemFont(ofSize: 16)
        sendButton.isEnabled = false
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAutomaticRowHeights = true
        tableView.intercellSpacing = NSSize(width: 0, height: 20)
        
        let assistantResultNib = NSNib(nibNamed: NSNib.Name("AssistantResultTableCellView"), bundle: nil)
        tableView.register(assistantResultNib, forIdentifier: AssistantResultTableCellView.identifier)
        let userResultNib = NSNib(nibNamed: NSNib.Name("UserResultTableCellView"), bundle: nil)
        tableView.register(userResultNib, forIdentifier: UserResultTableCellView.identifier)

    }
    
    @IBAction func didTapClear(_ sender: Any) {
        clearChatBox.isHidden = true
        messages = []
        emptyStackView.isHidden = false
        tableView.reloadData()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        removeChildFromNavigation()
    }
}

extension TopicViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let message = messages[row]
        
        if message.role == Role.user.rawValue {
            guard let cell = tableView.makeView(withIdentifier: UserResultTableCellView.identifier, owner: nil) as? UserResultTableCellView else {
                fatalError()
            }
            
            cell.configure(with: message)
            return cell
        } else if message.role == Role.assistant.rawValue {
            guard let cell = tableView.makeView(withIdentifier: AssistantResultTableCellView.identifier, owner: nil) as? AssistantResultTableCellView else {
                fatalError()
            }
            guard message.content.isNotEmpty else {
                cell.showAndPlay()
                return cell
            }
            
            cell.row = row
            cell.delegate = self
            cell.configure(with: message)
            return cell
        }
        return nil
    }
}

extension TopicViewController {
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
                emptyStackView.isHidden = true
                textInputBox.sendButtonState = .canStop
                startStreamTimer()
                
                let response = try await api.funcionsCall(text: prompt, model: GPTService.Constants.GPT4o, systemText: systemText ?? "You are an expert mathematics assistant. Solve any math problem accurately with clear, step-by-step explanations using proper LaTeX notation. Stay focused only on mathematics.")
                
                await MainActor.run {
                    self.responseString = response
                    self.currentStreamIndex = 0
                    self.startCharacterStreaming()
                }
                
                AppConstants.requestCount += 1
                App.incrementFreeAICount()
                if AppConstants.requestCount.isEven, AppConstants.requestCount > 0 {
                    SKStoreReviewController.requestReview()
                }
                
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
        let cell = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? AssistantResultTableCellView
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            messages[index].content.append(message)
            cell?.stream(messages[index].content)
        }
    }
}

extension TopicViewController {
    func startStreamTimer() {
        guard streamTimer == nil else { return }
        isStreaming = true
        streamTimer = Timer.scheduledTimer(timeInterval: 0.23, target: self, selector: #selector(scrollStream), userInfo: nil, repeats: true)
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

extension TopicViewController : InputBoxDelegate {
    func textInputBox(_ box: InputBox, didTapSendWithText text: String) {
        
        guard App.isPro || App.canSendQuery else {
            // TODO: Show Premium Screen Here
            showPremiumScreen()
            return
        }
        if isNetConnected {
            sendMessage(prompt: text)
        } else {
            showNoInternetAlert()
        }
    }
    
    func textInputBoxDidTapStop(_ box: InputBox) {
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

extension TopicViewController : TableResultViewCellDelegate {
    func tableCellView(_ cell: NSTableCellView, didTapCopyForRow row: Int) {
        api.task?.cancel()
        task?.cancel()
        let text = messages[row].content
        let button = (cell as? AssistantResultTableCellView)?.copyButton
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
    
    func tableCellView(_ cell: NSTableCellView, didTapShareForRow row: Int) {
        api.task?.cancel()
        task?.cancel()
        let text = messages[row].content
        let sharingPicker = NSSharingServicePicker.init(items: [text])
        if let button = (cell as? AssistantResultTableCellView)?.shareButton {
            let location = button.convert(view.bounds, to: button)
            sharingPicker.show(relativeTo: location, of: button, preferredEdge: .minY)
        }
    }
    
    func tableCellView(_ cell: NSTableCellView, didTapSpeakForRow row: Int) {
        api.task?.cancel()
        task?.cancel()
        let text = messages[row].content
        let button = (cell as? AssistantResultTableCellView)?.playButton
        if speakerManager.isSpeaking {
            DispatchQueue.main.async {
                button?.image = .speak
            }
            if let activeIndex = speakerManager.activeCellIndex,
               activeIndex != row {
                speakerManager.stopSpeaking()
                speakerManager.speak(text, cellIndex: row)
            } else {
                speakerManager.stopSpeaking()
            }
        } else {
            DispatchQueue.main.async {
                button?.image = .speaking
            }
            speakerManager.speak(text, cellIndex: row)
        }
    }
}
