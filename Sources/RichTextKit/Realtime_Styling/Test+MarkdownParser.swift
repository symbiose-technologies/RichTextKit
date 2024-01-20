//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 9/21/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation

import SwiftTreeSitter
import TreeSitterDocument
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import Combine
import SwiftUI


public class SymMarkdownParser {
    
    private(set) public var tree: LanguageLayerTree? = nil
    
    
    public init(invalidationHandler: LanguageLayerTree.InvalidationHandler? = nil ) throws {
        self.tree = try self.createTree(invalidationHandler)
    }
    
    public func replaceTextWith(_ source: String) {
        
    }
    
    
    public func highlightString(source: String) throws -> NSAttributedString {
        let highlights = try self.getHighlightsFor(source: source)
        return styleSourceString(namedRanges: highlights, source: source)
    }
    
//    public func replaceAnnotatedWith(source: String) {
//        do {
//            let annotated = try self.highlightStringSwiftUI(source: source)
//            self.annotated = annotated
//        } catch {
//            print("Error: \(error)")
//        }
//    }
    
    @available(macOS 12, iOS 16, *)
    public func highlightStringSwiftUI(source: String) throws -> AttributedString {
        let attr = try self.highlightString(source: source)
        return try AttributedString(attr, including: \.swiftUI)
    }
    
    public func getHighlightsFor(source: String) throws -> [NamedRange] {
        guard let tree = self.tree else {
            throw LanguageLayerError.noRootNode
        }
        
        tree.replaceContent(with: source)

        let fullRange = NSRange(source.startIndex..<source.endIndex, in: source)

        let membershipProvider: SwiftTreeSitter.Predicate.GroupMembershipProvider = { query, range, _ in
            guard query == "local" else { return false }
            return false
        }
        let context = SwiftTreeSitter.Predicate.Context(
            textProvider: source.cursorTextProvider,
            groupMembershipProvider: membershipProvider
        )
        
        let highlights = try tree.highlights(in: fullRange, context: context)

        for namedRange in highlights {
            print("\(namedRange.name): \(namedRange.range)")
        }
        return highlights
    }
    
    
    
    public func setup() throws {
        if let tree = try? self.createTree() {
            self.tree = tree
//            let source = self.rawTxt
//            try self.getHighlightsFor(source: source)
        }
    }
    
    
    private func createTree(_ invalidationHandler: LanguageLayerTree.InvalidationHandler? = nil ) throws -> LanguageLayerTree {
        let markdownConfig = try LanguageConfiguration(
            tsLanguage: tree_sitter_markdown(),
            name: "Markdown"
        )
        let markdownInlineConfig = try LanguageConfiguration(tsLanguage: tree_sitter_markdown_inline(),
                                                             name: "MarkdownInline",
                                                             bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline")
//        let swiftConfig = try LanguageConfiguration(tsLanguage: tree_sitter_swift(), name: "Swift")

        let config = LanguageLayerTree.Configuration(locationTransformer: nil,
                                                    invalidationHandler: invalidationHandler,
                                                    languageProvider: { name in
            switch name {
            case "markdown":
                return markdownConfig
            case "markdown_inline":
                return markdownInlineConfig
//            case "swift":
//                return swiftConfig
            default:
                return nil
            }
        })

        return try LanguageLayerTree(rootLanguageConfig: markdownConfig, configuration: config)

    }
    
}

#if canImport(UIKit)
import UIKit

public func styleSourceString(namedRanges: [NamedRange], source: String) -> NSAttributedString {
    let mutableAttributedString = NSMutableAttributedString(string: source)
    
    // Define styles
    let styles: [String: [NSAttributedString.Key: Any]] = [
        "text.literal": [.foregroundColor: UIColor.blue],
        "punctuation.delimiter": [.foregroundColor: UIColor.gray],
        "text.emphasis": [.font: UIFont.italicSystemFont(ofSize: 12)],
        "text.strong": [.font: UIFont.boldSystemFont(ofSize: 12)],
        "text.uri": [.link: true],
        "text.reference": [.underlineStyle: NSUnderlineStyle.single.rawValue],
        "string.escape": [.foregroundColor: UIColor.purple],
        "text.title": [.font: UIFont.boldSystemFont(ofSize: 16)],
        "punctuation.special": [.foregroundColor: UIColor.orange]
    ]

    // Apply styles
    for namedRange in namedRanges {
        let nsRange = NSRange(namedRange.tsRange.bytes)
        
        if let style = styles[namedRange.name] {
            mutableAttributedString.addAttributes(style, range: nsRange)
        }
    }
    
    return mutableAttributedString
}


#elseif canImport(AppKit)
import AppKit

public func styleSourceString(namedRanges: [NamedRange], source: String) -> NSAttributedString {
    let mutableAttributedString = NSMutableAttributedString(string: source)
    
    // Define styles
    let styles: [String: [NSAttributedString.Key: Any]] = [
        "text.literal": [.foregroundColor: NSColor.blue],
        "punctuation.delimiter": [.foregroundColor: NSColor.gray],
        "text.emphasis": [.font: NSFont.systemFont(ofSize: 12, weight: .regular)],
        "text.strong": [.font: NSFont.systemFont(ofSize: 12, weight: .bold)],
        "text.uri": [.link: true],
        "text.reference": [.underlineStyle: NSUnderlineStyle.single.rawValue],
        "string.escape": [.foregroundColor: NSColor.purple],
        "text.title": [.font: NSFont.systemFont(ofSize: 16, weight: .bold)],
        "punctuation.special": [.foregroundColor: NSColor.orange]
    ]
    
    // Apply styles
    for namedRange in namedRanges {
//        let nsRange = NSRange(namedRange.range)
        let nsRange = namedRange.range
        
        // Check that the NSRange is valid
        if nsRange.location + nsRange.length <= mutableAttributedString.length {
            if let style = styles[namedRange.name] {
                mutableAttributedString.addAttributes(style, range: nsRange)
            }
        } else {
            print("Range out of bounds: \(namedRange)")
        }
    }
    
    return mutableAttributedString
}


#endif
