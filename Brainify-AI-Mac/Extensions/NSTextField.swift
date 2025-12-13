//
//  Untitled.swift
//  EmoTalk
//
//  Created by Hasna Fiaz on 20/11/2025.
//

import Cocoa

extension NSTextField {
    func bestHeight(for text: String, width: CGFloat) -> CGFloat {
        stringValue = text
        let height = cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)).height
        return height
    }
    
    func bestWidth(for text: String, height: CGFloat) -> CGFloat {
        stringValue = text
        let width = cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height)).width
        return width
    }
}

extension NSTextField {

    func setText(
        _ words: [String],
        color: NSColor,
        font: NSFont,
        lineSpacing: CGFloat = 0.0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        numberOfLines: Int = 0,
        alignment: NSTextAlignment = .left
    ) {
        guard let labelText = self.stringValue as NSString? else {
            return
        }

        let attributedString = NSMutableAttributedString(string: labelText as String)

        for word in words {
            let range = labelText.range(of: word, options: .caseInsensitive)

            if range.location != NSNotFound {
                attributedString.addAttributes([
                    .foregroundColor: color,
                    .font: font
                ], range: range)
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = alignment

        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        self.attributedStringValue = attributedString
        self.maximumNumberOfLines = numberOfLines
    }
    func setAttributedText(
        _ words: [String],
        color: [NSColor],
        font: [NSFont],
        lineSpacing: CGFloat = 0.0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        numberOfLines: Int = 0,
        alignment: NSTextAlignment = .left,
        isStrikeThrough: Bool = false
    ) {
        guard let labelText = self.stringValue as NSString? else {
            return
        }

        let attributedString = NSMutableAttributedString(string: labelText as String)

        for index in 0..<words.count {
            let range = labelText.range(of: words[index], options: .caseInsensitive)

            if range.location != NSNotFound {
                attributedString.addAttributes([
                    .foregroundColor: color[index],
                    .font: font[index]
                ], range: range)
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = alignment

        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        if isStrikeThrough {
            attributedString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.thick.rawValue,
                range: NSRange(location: 0, length: attributedString.length)
            )
        }

        self.attributedStringValue = attributedString
        self.maximumNumberOfLines = numberOfLines
    }

    func setAttributedStrike(color: NSColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
            .foregroundColor: color
        ]
        attributedStringValue = NSAttributedString(string: stringValue, attributes: attributes)
    }

    func setLineSpacing(_ spacing: CGFloat, textAlignment: NSTextAlignment = .center) {
        guard let labelText = stringValue as NSString? else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = textAlignment

        let attributedString = NSAttributedString(
            string: labelText as String,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        attributedStringValue = attributedString
    }

}
