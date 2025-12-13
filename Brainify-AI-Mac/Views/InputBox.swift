//
//  InputBox.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 10/12/2025.
//

import Cocoa
import Vision
import PDFKit

protocol InputBoxDelegate: AnyObject {
    func textInputBox(_ box: InputBox, didTapSendWithText text: String)
    func textInputBoxDidTapStop(_ box: InputBox)
}

class InputBox: NSBox {
    
    enum SendButtonState {
        case canSend, canStop
    }
    @IBOutlet weak var placeholderTextView: PlaceHolderTextView!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var calculator: NSButton!
    @IBOutlet weak var attachmentsButton: NSButton!
    weak var delegate: InputBoxDelegate?
    
    private var calculatorPopup: NSView?
    private var calculatorViewController: CalculatorViewController?
    private var calculatorWindow: NSPopover?
    var popover = NSPopover()
    
    var sendButtonState: SendButtonState = .canSend {
        didSet { updateSendButtonState() }
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
            sendButton.isEnabled = true
            textViewDidChange()
        case .canStop:
            sendButton.isEnabled = false
            borderColor = .stroke
        }
    }
    
    func updateSendButtonEnabled(_ enabled: Bool) {
        guard sendButtonState == .canSend else {
            sendButton.isEnabled = true
            borderColor = .brand
            return
        }
        sendButton.isEnabled = enabled
    }
    
    func setText(_ text: String) {
        placeholderTextView.string = text
        textViewDidChange()
    }
    
    @IBAction func didTapAttachment(_ sender: NSButton) {
        let menu = NSMenu()
        let selectPhotoItem = NSMenuItem(title: "Select Photo".localized(), action: #selector(didTapSelectPhotoAttachment), keyEquivalent: "")
        selectPhotoItem.target = self
        let selectPDFItem = NSMenuItem(title: "Select PDF".localized(), action: #selector(didTapSelectPDFAttachment), keyEquivalent: "")
        selectPDFItem.target = self
        
        menu.items = [selectPhotoItem, selectPDFItem]
        let location = CGPointMake((sender).bounds.origin.x, -40)
        menu.popUp(positioning: nil, at: location, in: sender)
    }
    
    @IBAction func didTapCalculator(_ sender:  NSButton) {
        if isCalculatorOpen {
            closeCalculator()
        } else {
            openCalculatorPopover(from: sender)
            updateCalculatorButtonState()
        }
    }
    @IBAction func sendButtonTapped(_ sender: NSButton) {
        if popover.isShown {
            popover.close()
        }
        guard !placeholderTextView.string.isBlank else { return }
        let sendableText = placeholderTextView.string.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.textInputBox(self, didTapSendWithText: sendableText)
    }
    
    @objc func textViewDidChange() {
        updateSendButtonEnabled(!placeholderTextView.string.isEmpty && !placeholderTextView.string.isBlank)
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

extension InputBox {
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

extension InputBox: PlaceHolderTextViewDelegate {
    func placeHolderTextView(_ textView: PlaceHolderTextView, didTapSendWithText text: String) {
        guard sendButtonState == .canSend else { return }
        sendButtonTapped(sendButton)
    }
    
    func placeHolderTextView(_ textView: PlaceHolderTextView, textDidChange text: String) {}
    
    func recalculateHeight() {
        (placeholderTextView.enclosingScrollView as? GrowingTextScrollView)?.recalcHeight()
    }
}

extension InputBox {
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
            guard let self = self else { return }
            if let basicVC = calculatorVC.tabView.tabViewItem(at: 0).viewController as? BasicCalculatorViewController {
                basicVC.hideAbleStackView()
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

extension InputBox: BasicCalculatorDelegate {
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
