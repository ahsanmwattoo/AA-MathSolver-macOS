//
//  ResultViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 29/11/2025.
//

import Cocoa
import Lottie

protocol ResultViewControllerDelegate: AnyObject {
    func resultViewControllerDidSolve(_ controller: ResultViewController, image: NSImage)
    func resultViewControllerDidTapBack(_ controller: ResultViewController)
}

class ResultViewController: BaseViewController {

    static var identifier = "ResultViewController"
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var solveButton: NSButton!
    @IBOutlet weak var readyToSolveLabel: NSTextField!
    @IBOutlet weak var backButton: NSButton!
    
    var image: NSImage?
    weak var delegate: ResultViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        animationView.loopMode = .loop
        animationView.stop()
        animationView.isHidden = true
        solveButton.isEnabled = true
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            readyToSolveLabel.stringValue = "Ready to Solve".localized()
        }
    }
    
    @IBAction func didTapBack(_ sender: NSButton) {
        animationView.stop()
        dismiss(nil)
        delegate?.resultViewControllerDidTapBack(self)
       
    }
    
    @IBAction func didTapSolve(_ sender: NSButton) {
       // backButton.isEnabled = false
        if isNetConnected {
            animationView.isHidden = false
            animationView.play()
            if let image {
                delegate?.resultViewControllerDidSolve(self, image: image)
            }
            solveButton.isEnabled = false
        } else {
           // backButton.isEnabled = true
            showNoInternetAlert()
        }
    }
}
