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
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var solveLabel: NSTextField!
    @IBOutlet weak var solveBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var solveBox: NSBox!
    @IBOutlet weak var solveButton: NSButton!
    
    private let service = GPTService()
    private var task: Task<(), Never>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupDragView()
        textInputBox.delegate = self
        textView.placeholderString = "Ask anything...".localized()

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
            guard let self = self else { return }
            
            if !self.isFileSizeValid(url: url, maxSizeMB: 10) {
                return
            }
            
            if let image = NSImage(contentsOf: url) {
                let resultVC = ResultViewController(nibName: ResultViewController.identifier, bundle: nil)
                resultVC.image = image
                resultVC.delegate = self
                self.presentAsSheet(resultVC)
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
            
        openPanel.beginSheetModal(for: window) { [weak self] result in
            guard let self = self else { return }
                
            guard result == .OK,
                    let url = openPanel.url else { return }
                
                // Size check before loading image
            if !self.isFileSizeValid(url: url, maxSizeMB: 10) {
                return
            }
                
            guard let image = NSImage(contentsOf: url) else {
                Utility.showAlert(
                    title: "Error".localized(),
                    message: "Unable to load the selected image.".localized(),
                    okTitle: "OK".localized(),
                    window: window
                )
                return
            }
                
            DispatchQueue.main.async {
                let resultVC = ResultViewController(nibName: "ResultViewController", bundle: nil)
                resultVC.image = image
                resultVC.delegate = self
                self.presentAsSheet(resultVC)
            }
        }
    }
    
    private func isFileSizeValid(url: URL, maxSizeMB: Int) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? NSNumber {
                let fileSizeMB = fileSize.doubleValue / (1024 * 1024)
                if fileSizeMB > Double(maxSizeMB) {
                    DispatchQueue.main.async { [weak self] in
                        guard let window = self?.view.window else { return }
                        Utility.showAlert(
                            title: "File Too Large".localized(),
                            message: "Please select an image smaller than \(maxSizeMB) MB.".localized(),
                            okTitle: "OK".localized(),
                            window: window
                        )
                    }
                    return false
                }
            }
            return true
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let window = self?.view.window else { return }
                Utility.showAlert(
                    title: "Error".localized(),
                    message: "Unable to check file size.".localized(),
                    okTitle: "OK".localized(),
                    window: window
                )
            }
            return false
        }
    }
    
    func solveImage(_ image: NSImage, viewController: ResultViewController) {
        guard App.isPro || App.canSendQuery else {
            showPremiumScreen()
            return
        }
        
        guard let imageString = image.toBase64() else { return }
        
        if isNetConnected {
            weak var weakResultVC = viewController
            
            task = Task { [weak self] in
                guard let self else { return }
                
                do {
                    let input: InputOutput = .init(
                        role: .user,
                        content: [.init(imageURL: "data:image/jpeg;base64,\(imageString)")]
                    )
                    
                    let instructions = "Solve this math problem and provide steps, with proper formatting, if it isn't math problem, just reply with: Kindly provide a math problem image."
                    
                    let response = try await service.getResponse(model: GPTService.Constants.GPT4o, input: [input], instructions: instructions)
                    
                    AppConstants.requestCount += 1
                    App.incrementFreeAIMathCount()
                    SKStoreReviewController.requestReview()
                    
                    let id = UUID().uuidString
                    let problemText = "Image-based Math Problem"
                    let problemImageData = image.jpegData(compressionQuality: 0.8) ?? Data()
                    let date = Date()
                    
                    _ = try MathRepository.shared.createNewChat(
                        id: id,
                        problemText: problemText,
                        problemImage: problemImageData,
                        solution: response,
                        date: date
                    )
                    
                    await MainActor.run {
                        if weakResultVC?.presentingViewController == nil && weakResultVC?.isViewLoaded == true {
                            // ResultVC already dismissed → user cancelled → mat dikhao result
                            return
                        }
                        
                        self.showResult(problemImage: image, soltutionText: response)
                    }
                    
                } catch {
                    await MainActor.run {
                        // Error case mein bhi dismiss kar do agar abhi presented hai
                        if weakResultVC?.presentingViewController != nil {
                            viewController.dismiss(nil)
                        }
                    }
                    print("Error: \(error)")
                    self.showAlert(title: "Error".localized(), message: "Failed to connect to server. Please check your internet connection.".localized())
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
                    SKStoreReviewController.requestReview()                    // Prepare data for CoreData
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
    func resultViewControllerDidTapBack(_ controller: ResultViewController) {
        task?.cancel()
        service.task?.cancel()
    }
    
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
