//
//  String+Extension.swift
//  AmityUIKit4
//
//  Created by Zay Yar Htun on 1/16/24.
//

import UIKit

extension String {
    public var localizedString: String {
            return NSLocalizedString(self, tableName: "AmityLocalizable", bundle: AmityUIKit4Manager.bundle, value: "", comment: "")
    }
    
    func localized(arguments: CVarArg...) -> String {
        let localizedText = NSLocalizedString(self, tableName: "AmityLocalizable", bundle: AmityUIKit4Manager.bundle, value: "", comment: "")
        let formattedText = String(format: localizedText, arguments: arguments)
        return formattedText
    }
    
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }
    
    func size(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

// MARK: - HTML-authored text

/// `&amp;` must be decoded last, so `&amp;lt;` becomes the literal text `&lt;` and not `<`.
private let amityNamedHTMLEntities: [(entity: String, replacement: String)] = [
    ("&nbsp;", "\u{00A0}"),
    ("&lt;", "<"),
    ("&gt;", ">"),
    ("&quot;", "\""),
    ("&apos;", "'"),
    ("&hellip;", "…"),
    ("&mdash;", "—"),
    ("&ndash;", "–"),
    ("&lsquo;", "‘"),
    ("&rsquo;", "’"),
    ("&ldquo;", "“"),
    ("&rdquo;", "”"),
    ("&amp;", "&")
]

extension String {

    /// Zuddl authors community descriptions as rich text, so Amity can hand back raw HTML.
    var looksLikeHTML: Bool {
        return range(of: "<\\s*/?\\s*[a-zA-Z][^<>]*>", options: .regularExpression) != nil
            || range(of: "&(#[0-9]+|#[xX][0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]{1,31});", options: .regularExpression) != nil
    }

    /// Non-HTML input is returned untouched so a user-typed `<` or `&` is never mangled.
    /// Avoids `NSAttributedString(documentType: .html)`, which is main-thread-only and slow.
    func htmlToPlainText() -> String {
        guard looksLikeHTML else {
            return trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var text = replacingOccurrences(
            of: "<\\s*br\\s*/?\\s*>|<\\s*/\\s*(p|div|li|tr|h[1-6]|blockquote)\\s*>",
            with: "\n",
            options: [.regularExpression, .caseInsensitive]
        )
        text = text.replacingOccurrences(of: "<[^<>]+>", with: "", options: .regularExpression)
        text = text.decodingHTMLEntities()
        text = text.replacingOccurrences(of: "[ \\t]*\\n[ \\t]*", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func decodingHTMLEntities() -> String {
        var result = decodingNumericHTMLEntities()
        for (entity, replacement) in amityNamedHTMLEntities {
            result = result.replacingOccurrences(of: entity, with: replacement, options: .caseInsensitive)
        }
        return result
    }

    private func decodingNumericHTMLEntities() -> String {
        guard let regex = try? NSRegularExpression(pattern: "&#([xX][0-9a-fA-F]+|[0-9]+);") else {
            return self
        }
        let source = self as NSString
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: source.length))
        guard !matches.isEmpty else { return self }

        var result = ""
        var cursor = 0
        for match in matches {
            result += source.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
            let body = source.substring(with: match.range(at: 1))
            let isHex = body.lowercased().hasPrefix("x")
            let digits = isHex ? String(body.dropFirst()) : body
            if let code = UInt32(digits, radix: isHex ? 16 : 10), let scalar = Unicode.Scalar(code) {
                result.append(Character(scalar))
            } else {
                result += source.substring(with: match.range)
            }
            cursor = match.range.location + match.range.length
        }
        result += source.substring(from: cursor)
        return result
    }
}
