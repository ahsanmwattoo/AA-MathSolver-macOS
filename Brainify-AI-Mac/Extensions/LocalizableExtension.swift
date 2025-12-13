//
//  LocalizableExtension.swift
//  DownTik
//
//  Created by Abdullah Haq  on 23/07/2025.
//

import AppKit

class LocalizableTextField: NSTextField {
  var key: String?
  var placeHolderKey: String?
   
  @IBInspectable var stringValueKey: String? {
    get {
      return key
    }
    set {
      key = newValue
    }
  }
   
  @IBInspectable var placeholderStringKey: String? {
    get {
      return placeHolderKey
    }
    set {
      placeHolderKey = newValue
    }
  }
}

class LocalizableButton: NSButton {
  var key: String?
   
  @IBInspectable var titleKey: String? {
    get {
      return key
    }
    set {
      key = newValue
    }
  }
}


extension NSTextField {
  func localize() {
    if let self = self as? LocalizableTextField {
      stringValue = self.key?.localized() ?? stringValue
      placeholderString = self.placeHolderKey?.localized() ?? placeholderString
    }
  }
}

extension NSButton {
  func localize() {
    if let self = self as? LocalizableButton {
      title = self.key?.localized() ?? title
    }
  }
}

extension NSView {
  func localizeSubviews() {
    for view in self.subviews {
      if let textField = view as? NSTextField {
        textField.localize()
      }
       
      if let button = view as? NSButton {
        button.localize()
      }
       
      if let textView = view as? PlaceHolderTextView {
        textView.string = textView.key?.localized() ?? textView.string
        textView.placeholderString = textView.placeholderStringKey?.localized() ?? textView.placeholderString
      }
       
      if let collectionView = view as? NSCollectionView {
        let selectionIndexPaths = collectionView.selectionIndexPaths
        collectionView.reloadWithSelectedIndexPaths()
        collectionView.selectItems(at: selectionIndexPaths, scrollPosition: .nearestHorizontalEdge)
      }
       
      if let tableView = view as? NSTableView {
        tableView.reloadVisibleRows()
      }
       
      if let box = view as? NSBox {
        box.subviews.forEach { $0.localizeSubviews() }
      }
       
      view.localizeSubviews()
    }
  }
}
