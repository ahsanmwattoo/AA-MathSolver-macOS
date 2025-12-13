//
//  SplashViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 25/11/2025.
//

import Cocoa

class SplashViewController: BaseViewController {

    static var identifier = "SplashViewController" 
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didChangeLanguage() {
        super.didChangeLanguage()
        titleLabel.stringValue = "Brainify".localized()
        subtitleLabel.stringValue = "AI Math Solver".localized()
    }
}
