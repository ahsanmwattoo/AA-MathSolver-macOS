//
//  LottieOverlay.swift
//  EmoTalk
//
//  Created by Macbook Pro on 13/10/2025.
//

import Cocoa
import Lottie

class LottieOverlay: NoClickView {
    private var lottieAnimationView: LottieAnimationView?
    private var clearButton: NSButton!
    
    init(frame frameRect: NSRect, animationName: String) {
        super.init(frame: frameRect)
        setupOverlay()
        setupLottieAnimation(animationName: animationName)
        setupClearButton()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupOverlay()
        setupLottieAnimation(animationName: "instaLoaderAnimation2")
        setupClearButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
        setupLottieAnimation(animationName: "instaLoaderAnimation2")
        setupClearButton()
    }
    
    private func setupOverlay() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
    }
    
    private func setupLottieAnimation(animationName: String) {
        lottieAnimationView = LottieAnimationView(name: animationName)
        guard let lottieAnimationView = lottieAnimationView else { return }
        
        lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.alphaValue = 0.4
        addSubview(lottieAnimationView)
        
        NSLayoutConstraint.activate([
            lottieAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lottieAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lottieAnimationView.widthAnchor.constraint(equalToConstant: 300),
            lottieAnimationView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupClearButton() {
        clearButton = NSButton()
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.title = ""
        clearButton.isBordered = false
        clearButton.wantsLayer = true
        clearButton.layer?.backgroundColor = NSColor.clear.cgColor
        
        addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            clearButton.topAnchor.constraint(equalTo: topAnchor),
            clearButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        clearButton.isEnabled = false
    }
    
    func playAnimation() {
        isHidden = false
        lottieAnimationView?.play()
    }
    
    func stopAnimation() {
        lottieAnimationView?.stop()
        isHidden = true
    }
}
