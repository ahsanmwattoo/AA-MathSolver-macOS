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
}

class ResultViewController: BaseViewController {

    static var identifier = "ResultViewController"
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var solveButton: NSButton!
    @IBOutlet weak var readyToSolveLabel: NSTextField!
    
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
        readyToSolveLabel.stringValue = "Ready to Solve".localized()
        
    }
    
    @IBAction func didTapBack(_ sender: NSButton) {
        animationView.stop()
        dismiss(nil)
        delegate = nil
    }
    
    @IBAction func didTapSolve(_ sender: NSButton) {
        if isNetConnected {
            animationView.isHidden = false
            animationView.play()
            if let image {
                delegate?.resultViewControllerDidSolve(self, image: image)
            }
            solveButton.isEnabled = false
        } else {
            showNoInternetAlert()
        }
    }
}
