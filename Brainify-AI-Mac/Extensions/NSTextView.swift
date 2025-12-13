//
//  File.swift
//  EmoTalk
//
//  Created by Macbook Pro on 13/10/2025.
//

import Foundation
import AppKit

protocol PlaceHolderTextViewDelegate: AnyObject {
  func placeHolderTextView(_ textView: PlaceHolderTextView, didTapSendWithText text: String)
  func placeHolderTextView(_ textView: PlaceHolderTextView, textDidChange text: String)
}

class PlaceHolderTextView: NSTextView {
   
  var key: String?
  var placeholderKey: String?
   
  weak var textViewDelegate: PlaceHolderTextViewDelegate?
   
  @IBInspectable var stringKey: String? {
    get {
      key
    }
    set {
      key = newValue
    }
  }
   
  @IBInspectable var placeholderStringKey: String? {
    get {
      placeholderKey
    }
    set {
      placeholderKey = newValue
    }
  }
   
  // MARK: - Placeholder
  @IBInspectable var placeholderString: String = "Placeholder" {
    didSet {
      needsDisplay = true
    }
  }
   
  @IBInspectable var placeholderTextColor: NSColor = .placeholderTextColor {
    didSet {
      needsDisplay = true
    }
  }

  // MARK: - Initializers
  override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
    configure()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }

  private func configure() {
    drawsBackground = true
    postsFrameChangedNotifications = true

    NotificationCenter.default.addObserver(self,
                        selector: #selector(textDidChange(_:)),
                        name: NSText.didChangeNotification,
                        object: self)
  }

  deinit {
//      stopColorCycling()
    NotificationCenter.default.removeObserver(self)
  }
   
  //MARK: - KeyDonw
  override func keyDown(with event: NSEvent) {
      let isEnter = event.keyCode == 36 || event.keyCode == 76 // Return and Enter keys
      let shiftPressed = event.modifierFlags.contains(.shift)

      if isEnter && !shiftPressed {
        // Call send instead of inserting newline
        textViewDelegate?.placeHolderTextView(self, didTapSendWithText: string)
        // Do not call super, so no newline is inserted
      } else {
        // For shift+enter or any other key, default behavior (insert newline)
        super.keyDown(with: event)
      }
    }

  // MARK: - Draw
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
     
    guard string.isEmpty else { return }
     
    let placeholderAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: placeholderTextColor,
      .font: self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
    ]

    let placeholderRect = NSMakeRect(5, 0, bounds.width - 10, bounds.height)
    placeholderString.draw(in: placeholderRect, withAttributes: placeholderAttributes)
  }

  // MARK: - Notifications
  @objc private func textDidChange(_ notification: Notification) {
    needsDisplay = true
    textViewDelegate?.placeHolderTextView(self, textDidChange: string)
  }
    
//    private let colors: [NSColor] = [
//           .gradient2,
//           .gradient1,
//           .appPurple,
//           .gradient5,
//           .gradient2
//       ]
//
//       private var currentColorIndex: Int = 0
//       private var colorChangeTimer: Timer?
//
//       // IBInspectable to enable/disable color cycling
//       @IBInspectable
//       var cycleColors: Bool = false {
//           didSet {
//               if cycleColors {
//                   startColorCycling()
//               } else {
//                   stopColorCycling()
//                   // Reset to a default color when cycling is disabled
//                   super.insertionPointColor = .textColor
//               }
//           }
//       }
//
//       override var insertionPointColor: NSColor? {
//           get {
//               return super.insertionPointColor
//           }
//           set {
//               super.insertionPointColor = newValue
//           }
//       }
//
//       override func awakeFromNib() {
//           super.awakeFromNib()
//           // Set initial color
//           super.insertionPointColor = colors.first ?? .textColor
//           // Start cycling if enabled in Interface Builder
//           if cycleColors {
//               startColorCycling()
//           }
//       }
//
//       private func startColorCycling() {
//           // Invalidate any existing timer
//           stopColorCycling()
//
//           // Create a timer to change colors every 0.5 seconds
//           colorChangeTimer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { [weak self] _ in
//               guard let self = self else { return }
//               self.currentColorIndex = (self.currentColorIndex + 1) % self.colors.count
//               insertionPointColor = self.colors[self.currentColorIndex]
//               self.needsDisplay = true
//           }
//       }
//
//       private func stopColorCycling() {
//           colorChangeTimer?.invalidate()
//           colorChangeTimer = nil
//       }
    
    @IBInspectable
       var cursorColor: NSColor? = .textColor {
           didSet {
               // Update the insertion point color when the property changes
               super.insertionPointColor = cursorColor ?? .textColor
               // Force redraw to reflect the change immediately in Interface Builder
               needsDisplay = true
           }
       }
       
       override var insertionPointColor: NSColor? {
           get {
               return cursorColor
           }
           set {
               // Ensure the cursor color is updated and stored
               cursorColor = newValue ?? .textColor
               super.insertionPointColor = newValue
           }
       }
       
       // Ensure the cursor color is applied when the view is initialized
       override func awakeFromNib() {
           super.awakeFromNib()
           super.insertionPointColor = cursorColor ?? .textColor
       }
       
}
