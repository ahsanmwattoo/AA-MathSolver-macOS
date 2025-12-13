//
//  TextInputBox.swift
//  ChatGPTmacAR
//
//  Created by Macbook Pro on 24/05/2025.
//

import Cocoa
import Vision
import Speech
import PDFKit

protocol TextInputBoxDelegate: AnyObject {
    func textInputBox(_ box: TextInputBox, didTapSendWithText text: String)
    func textInputBoxDidTapStop(_ box: TextInputBox)
}

class TextInputBox: NSBox {
    
    enum SendButtonState {
        case canSend, canStop
    }
    
    @IBOutlet weak var attachmentsButton: NSButton!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var placeholderTextView: PlaceHolderTextView!
    @IBOutlet weak var microphoneButton: NSButton!
    @IBOutlet weak var calculator: NSButton!
    @IBOutlet weak var sendBox: NSBox!
    @IBOutlet weak var stopButton: NSButton!
    
    weak var delegate: TextInputBoxDelegate?
    var microphoneIsOn: Bool = false
    var popover = NSPopover()
    let synthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer? { return SFSpeechRecognizer(locale: Locale(identifier: "en")) }
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var calculatorPopup: NSView?
    private var calculatorViewController: CalculatorViewController?
    private var calculatorWindow: NSPopover?
    
    var sendButtonState: SendButtonState = .canSend {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateSendButtonState()
            }
        }
    }
    
    var isRecording: Bool = false {
        didSet { updateRecordingButtonState() }
    }
    
    var isCalculatorOpen: Bool = false {
        didSet { updateCalculatorButtonState() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateSendButtonEnabled(false)
        
        placeholderTextView.textViewDelegate = self
        placeholderTextView.font = .systemFont(ofSize: 16, weight: .regular)
        placeholderTextView.placeholderTextColor = .placeholderTextColor
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange),
            name: NSText.didChangeNotification,
            object: placeholderTextView
        )
    }
    
    func updateRecordingButtonState() {
        if isRecording {
            startSpeechRecognition()
            microphoneButton.image = NSImage(named: "recording")
        } else {
            stopSpeechRecognition()
            microphoneButton.image = NSImage(named: "record")
        }
    }
    
    func updateCalculatorButtonState() {
        if isCalculatorOpen {
            calculator.image = NSImage(named: "calculatorselected")
        } else {
            calculator.image = NSImage(named: "equation")
        }
    }
    
    func updateSendButtonState() {
        switch sendButtonState {
        case .canSend:
            sendButton.isHidden = false
            stopButton.isHidden = true
            textViewDidChange()
        case .canStop:
            sendButton.isHidden = true
            stopButton.isHidden = false
            sendBox?.alphaValue = 0.5
        }
    }
    
    func updateSendButtonEnabled(_ enabled: Bool) {
        guard sendButtonState == .canSend else {
            self.borderColor = .brand
            sendButton.isEnabled = true
            return
        }
        sendButton.isEnabled = enabled
        self.borderColor = enabled ? .brand : .stroke
        sendBox?.alphaValue = enabled ? 1 : 0.5
    }
    
    func setText(_ text: String) {
        placeholderTextView.string = text
        textViewDidChange()
    }
    
    @objc func textViewDidChange() {
        updateSendButtonEnabled(!placeholderTextView.string.isEmpty && !placeholderTextView.string.isBlank)
    }
    
    
    @IBAction func stopButtonTapped(_ sender: NSButton) {
        delegate?.textInputBoxDidTapStop(self)
    }
    
    @IBAction func didTapAttachments(_ sender: NSButton) {
        let menu = NSMenu()
        let selectPhotoItem = NSMenuItem(title: "Select Photo".localized(), action: #selector(didTapSelectPhotoAttachment), keyEquivalent: "")
        selectPhotoItem.target = self
        let selectPDFItem = NSMenuItem(title: "Select PDF".localized(), action: #selector(didTapSelectPDFAttachment), keyEquivalent: "")
        selectPDFItem.target = self
        
        menu.items = [selectPhotoItem, selectPDFItem]
        let location = CGPointMake((sender).bounds.origin.x, -40)
        menu.popUp(positioning: nil, at: location, in: sender)
    }
    
    @IBAction func didTapCalculator(_ sender: NSButton) {
        if isCalculatorOpen {
            closeCalculator()
        } else {
            openCalculatorPopover(from: sender)
            updateCalculatorButtonState()
        }
    }
    
    @IBAction func didTapRecord(_ sender: Any) {
        isRecording.toggle()
    }
    
    @IBAction func sendButtonTapped(_ sender: NSButton) {
        if popover.isShown {
            popover.close()
        }
        
        isRecording = false
        guard !placeholderTextView.string.isBlank else { return }
        let sendableText = placeholderTextView.string.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.textInputBox(self, didTapSendWithText: sendableText)
    }
    
    @objc func didTapSelectPhotoAttachment() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let dialog = NSOpenPanel()
            dialog.title = "Choose an attachment to recognize text".localized()
            dialog.showsHiddenFiles = false
            dialog.allowsMultipleSelection = false
            dialog.canChooseDirectories = false
            dialog.allowedContentTypes = [.image]
            if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                guard let result = dialog.url else { return }
                if let image: NSImage = NSImage.init(contentsOf: result) {
                    self.processRecognizedTextFromImage(image: image)
                }
            } else {
                return
            }
        }
    }
    
    @objc func didTapSelectPDFAttachment() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let dialog = NSOpenPanel()
            dialog.title = "Chose a PDF File to recognize text".localized()
            dialog.showsHiddenFiles = false
            dialog.allowsMultipleSelection = false
            dialog.canChooseDirectories = false
            dialog.allowedContentTypes = [.pdf]
            if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                guard let result = dialog.url else { return }
                recognizeTextFromPDF(result) { [weak self] text in
                    guard let text else {
                        guard let window = self?.window else { return }
                        Utility.showAlert(title: "Error".localized(), message: "PDF does not contain any text. Please try different file.".localized(), okTitle: "Okay", window: window)
                        return
                    }
                    self?.placeholderTextView.string = text
                    self?.sendButtonState = .canSend
                }
            } else {
                return
            }
        }
    }
    
    func recognizeTextFromPDF(_ url: URL, completion: (String?) -> Void) {
        guard let pdfDocument = PDFDocument(url: url) else {
            completion(nil)
            return
        }
        
        var extractedText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
          if let page = pdfDocument.page(at: pageIndex),
            let pageText = page.string {
            extractedText += pageText + "\n"
          }
        }
         
        completion(extractedText.isBlank ? nil : extractedText)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextInputBox {
    func recognizeTextInImage(_ image: NSImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                print("Error recognizing text: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            let recognizedStrings = request.results?.compactMap { observation in
                return (observation as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
            }
        
            let recognizedText = recognizedStrings?.joined(separator: "\n")
            completion(recognizedText)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func processRecognizedTextFromImage(image: NSImage) {
        self.recognizeTextInImage(image) { [weak self] recognizedText in
            if let text = recognizedText?.replacingOccurrences(of: "\n", with: " ") {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    placeholderTextView.string = text
                    updateSendButtonEnabled(placeholderTextView.string.isNotEmpty)
                }
            } else {
                guard let window = self?.window else { return }
                Utility.showAlert(title: "Error".localized(), message: "Image does not contain any text. Please try different image.".localized(), okTitle: "Okay", window: window)
            }
        }
    }
}

extension TextInputBox: PlaceHolderTextViewDelegate {
    func placeHolderTextView(_ textView: PlaceHolderTextView, didTapSendWithText text: String) {
        guard sendButtonState == .canSend else { return }
        sendButtonTapped(sendButton)
    }
    
    func placeHolderTextView(_ textView: PlaceHolderTextView, textDidChange text: String) {}
    
    func recalculateHeight() {
        (placeholderTextView.enclosingScrollView as? GrowingTextScrollView)?.recalcHeight()
    }
}

extension TextInputBox {
    func speechReconitionAuthorized() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                if authStatus != .authorized {
                    continuation.resume(returning: false)
                }
                continuation.resume(returning: true)
            }
        }
    }
    
    func microphoneAuhtorized() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func startSpeechRecognition() {
        guard let recognizer = speechRecognizer else {
            print("Speech recognition is not available")
            return
        }
        
        Task {
            guard await microphoneAuhtorized() else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    let isYes = Utility.dialogOKCancel(question: "Please allow \(AppConstants.appName) to access your Microphone from device settings".localized(), yesButtonText: "Settings".localized(), noButtonText: "Cancel".localized())
                    if isYes {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    isRecording = false
                    return
                }
                return
            }
            
            guard await speechReconitionAuthorized() else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let isYes = Utility.dialogOKCancel(question: "Please allow \(AppConstants.appName) to access your Speech Recognition from device settings".localized(), yesButtonText: "Settings".localized(), noButtonText: "Cancel".localized())
                    
                    if isYes {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_SpeechRecognition") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    isRecording = false
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let isYes = Utility.dialogOKCancel(question: "Please allow \(AppConstants.appName) to access your Microphone from device settings".localized(), yesButtonText: "Settings".localized(), noButtonText: "Cancel".localized())
                    if isYes {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    isRecording = false
                    return
                }
                return
            }
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                
                return
            }
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
                guard let self = self else { return }
                if let result = result {
                    let transcription = result.bestTranscription.formattedString
                    if isRecording {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            placeholderTextView.string = transcription
                            updateSendButtonEnabled(placeholderTextView.string.isNotEmpty)
                        }
                    }
                } else if let error = error {
                    CZLogger.logError(error: error.localizedDescription)
                }
            })
            
            inputNode = audioEngine.inputNode
            let recordingFormat = inputNode?.outputFormat(forBus: 0)
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                guard let _ = self else { return }
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                return
            }
        }
    }
    
    func stopSpeechRecognition() {
        inputNode?.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        microphoneIsOn = false
    }
    
    private func openCalculatorPopover(from button: NSButton) {
        let calculatorVC = CalculatorViewController(nibName: "CalculatorViewController", bundle: nil)
        
        popover.contentViewController = calculatorVC
        popover.behavior = .applicationDefined
        popover.animates = true
        
        calculatorVC.preferredContentSize = NSSize(width: 980, height: 380)
        NotificationCenter.default.addObserver(
            forName: NSPopover.didShowNotification,
            object: popover,
            queue: .main
        ) { [weak self] _ in
            if let basicVC = calculatorVC.tabView.tabViewItem(at: 0).viewController as? BasicCalculatorViewController {
                basicVC.delegate = self
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSPopover.didCloseNotification,
            object: popover,
            queue: .main
        ) { [weak self] _ in
            self?.isCalculatorOpen = false
            self?.updateCalculatorButtonState()
        }
        
        popover.show(relativeTo: self.bounds, of: self, preferredEdge: .maxY)
        calculatorVC.isOpenedAsPopUp = true
        calculatorVC.view.wantsLayer = true
        calculatorVC.view.layer?.cornerRadius = 16
        calculatorVC.view.layer?.masksToBounds = true

        self.calculatorWindow = popover
        self.calculatorViewController = calculatorVC
        isCalculatorOpen = true
        updateCalculatorButtonState()
    }

    private func closeCalculator() {
        calculatorWindow?.close()
        calculatorWindow = nil
        calculatorViewController = nil
        isCalculatorOpen = false
        updateCalculatorButtonState()
    }
}

extension TextInputBox: BasicCalculatorDelegate {
    func calculatorDidClearText(_ calculator: BasicCalculatorViewController) {
        placeholderTextView.string = ""
    }
    
    func calculator(_ calculator: BasicCalculatorViewController, didUpdateExpression text: String) {
        if text == "BACKSPACE" {
            if !self.placeholderTextView.string.isEmpty {
                self.placeholderTextView.string.removeLast()
            }
            return
        }

        self.placeholderTextView.string += text
        self.updateSendButtonEnabled(!self.placeholderTextView.string.isEmpty)
    }
}
