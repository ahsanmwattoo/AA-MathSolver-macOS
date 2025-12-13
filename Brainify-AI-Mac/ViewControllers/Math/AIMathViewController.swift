//
//  AIMathViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa
import Foundation
import StoreKit

class AIMathViewController: BaseViewController {

    static var identifier = "AIMathViewController"
    
    @IBOutlet weak var dragBox: NSBox!
    @IBOutlet weak var offerBox: NSBox!
    @IBOutlet weak var offerLabelPortion: NSTextField!
    @IBOutlet weak var offerLabel: NSTextField!
    @IBOutlet weak var uploadView: DragView!
    @IBOutlet weak var titleLabel: NSTextFieldCell!
    @IBOutlet weak var dragLabel: NSTextField!
    @IBOutlet weak var dragLabelTwo: NSTextField!
    @IBOutlet weak var chooseFileLabel: NSTextField!
    @IBOutlet weak var supportedFormatLabel: NSTextField!
    @IBOutlet weak var offerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var textInputBox: TextInputBox!
    @IBOutlet var textView: PlaceHolderTextView!
    @IBOutlet weak var solveLabel: NSTextField!
    @IBOutlet weak var solveBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var solveBox: NSBox!
    @IBOutlet weak var solveButton: NSButton!
    
    private let service = GPTService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupDragView()
        textInputBox.delegate = self
    }
    
    func configureUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            dragBox.boxType = .custom
        }
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            textView.placeholderString = "Ask anything...".localized()
            offerLabelPortion.stringValue = "Upgrade to Premium now!".localized()
            offerLabelPortion.setText(["Upgrade to Premium now!".localized()], color: .button, font: NSFont.systemFont(ofSize: 14, weight: .bold))
            titleLabel.stringValue = "Solve your Math Problem!".localized()
            dragLabel.stringValue = "Drag and drop your file here".localized()
            dragLabelTwo.stringValue = "or choose a file from finder".localized()
            chooseFileLabel.stringValue = "Choose File".localized()
            supportedFormatLabel.stringValue = "Supported formats: JPG, PNG. Maximum size: 10 MB".localized()
            solveLabel.stringValue = "Solve".localized()
            configureWidth()
        }
    }
    
    func configureWidth() {
        let title = solveLabel.stringValue
        let textField = NSTextField()
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        let textWidth = textField.bestWidth(for: title, height: 40)
        let spacingAndImageWidth: CGFloat = 45.0
        let width = textWidth + spacingAndImageWidth
        solveBoxWidth.constant = width
    }
    
    private func setupDragView() {
        uploadView.fileUrlCallback = { [weak self] url in
            if let image = NSImage(contentsOf: url) {
                guard let self else { return }
                let resultVC = ResultViewController(nibName: ResultViewController.identifier, bundle: nil)
                resultVC.image = image
                resultVC.delegate = self
                presentAsSheet(resultVC)
            }
        }
    }
    
    @IBAction func didTapOffer(_ sender: Any) {
        let offerViewController = OfferViewController(nibName: OfferViewController.identifier, bundle: nil)
        presentAsSheet(offerViewController)
    }
    
    @IBAction func didTapChooseFile(_ sender: Any) {
        guard let window = view.window else { return }
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Image".localized()
        openPanel.prompt = "Choose".localized()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedContentTypes = [.jpeg, .png, .heic, .heif]
    
        openPanel.beginSheetModal(for: window) { result in
            guard result == .OK,
                    let url = openPanel.url,
                  let image = NSImage(contentsOf: url) else { return }
            
            DispatchQueue.main.async { [weak self] in
                let resultVC = ResultViewController(nibName: "ResultViewController", bundle: nil)
                resultVC.image = image
                resultVC.delegate = self
                self?.presentAsSheet(resultVC)
            }
        }
    }
    
    func solveImage(_ image: NSImage, viewController: ResultViewController) {
        guard let imageString = image.toBase64() else {
            return
        }
        if isNetConnected {
            Task {
                do {
                    let input: InputOutput = .init(
                        role: .user,
                        content: [.init(imageURL: "data:image/jpeg;base64,\(imageString)")]
                    )
                    
                    let instructions = "Solve this math problem and provide steps, with proper formatting, if it isn't math problem, just reply with: Kindly provide a math problem image."
                    
                    let response = try await service.getResponse(model: GPTService.Constants.GPT4o, input: [input], instructions: instructions)
                    AppConstants.requestCount += 1
                    
                    App.incrementFreeAIMathCount()
                    if AppConstants.requestCount.isEven, AppConstants.requestCount > 0 {
                        SKStoreReviewController.requestReview()
                    }
                    // Prepare data for CoreData
                    let id = UUID().uuidString
                    let problemText = "Image-based Math Problem"
                    let problemImageData = image.jpegData(compressionQuality: 0.8) ?? Data()
                    let date = Date()
                    
                    // Save to CoreData
                    _ = try MathRepository.shared.createNewChat(
                        id: id,
                        problemText: problemText,
                        problemImage: problemImageData,
                        solution: response,
                        date: date
                    )
                    
                    // Proceed to show result
                    DispatchQueue.main.async {
                        viewController.dismiss(nil)
                        self.showResult(problemImage: image, soltutionText: response)
                    }
                } catch {
                    DispatchQueue.main.async {
                        viewController.dismiss(nil)
                    }
                    print("Error: \(error)")
                    showAlert(title: "Error".localized(), message: "Failed to connect to server. Please check your internet connection.".localized())
                }
            }
        } else {
            showNoInternetAlert()
        }
    }

    func solveText(problemText: String) {
        
        if isNetConnected {
            showLoading()
            Task {
                do {
                    let input: InputOutput = .init(
                        role: .user,
                        content: [.init(text: problemText)]
                    )
                    
                    let instructions = "Solve this math problem and provide steps, with proper formatting, if it isn't math problem, just reply with: Kindly provide a math problem."
                    
                    let response = try await service.getResponse(model: GPTService.Constants.GPT4o, input: [input], instructions: instructions)
                    AppConstants.requestCount += 1
                    
                    App.incrementFreeAIMathCount()
                    if AppConstants.requestCount.isEven, AppConstants.requestCount > 0 {
                        SKStoreReviewController.requestReview()
                    }
                    // Prepare data for CoreData
                    let id = UUID().uuidString
                    let problemImageData = Data()
                    let date = Date()
                    
                    // Save to CoreData
                    _ = try MathRepository.shared.createNewChat(
                        id: id,
                        problemText: problemText,
                        problemImage: problemImageData,
                        solution: response,
                        date: date
                    )
                    
                    showResult(problemText: problemText, soltutionText: response)
                    hideLoading()
                } catch {
                    hideLoading()
                    print("Error: \(error)")
                    showAlert(title: "Error".localized(), message: "Failed to connect to server. Please check your internet connection.".localized())
                }
            }
        } else {
            hideLoading()
            showNoInternetAlert()
        }
    }
    
    func showResult(problemImage: NSImage, soltutionText: String) {
        DispatchQueue.main.async { [weak self] in
            let viewController = MathResultViewController(problemImage: problemImage, solutionText: soltutionText)
            self?.addChildToNavigation(viewController)
        }
    }
    
    func showResult(problemText: String, soltutionText: String ) {
        DispatchQueue.main.async { [weak self] in
            let viewController = MathResultViewController(problemText: problemText, solutionText: soltutionText)
            self?.addChildToNavigation(viewController)
        }
    }
}

extension AIMathViewController: ResultViewControllerDelegate {
    func resultViewControllerDidSolve(_ controller: ResultViewController, image: NSImage) {
        guard App.isPro || App.canSendQuery else {
            // TODO: Show Premium Screen Here
            showPremiumScreen()
            return
        }
        solveImage(image, viewController: controller)
    }
}

extension AIMathViewController: TextInputBoxDelegate {
    func textInputBox(_ box: TextInputBox, didTapSendWithText text: String) {
        guard App.isPro || App.canSendQuery else {
            // TODO: Show Premium Screen Here
            showPremiumScreen()
            return
        }
        solveText(problemText: text)
    }
    
    func textInputBoxDidTapStop(_ box: TextInputBox) {
        
    }
}

extension AIMathViewController {
    private func encodeMessagesToJSON(messages: [Message]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(messages)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding messages: \(error.localizedDescription)")
        }
        return nil
    }
}
