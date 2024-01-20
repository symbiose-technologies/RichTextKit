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

import Neon
import TreeSitterClient
import TreeSitterDocument

#if canImport(UIKit)
import UIKit
public extension UITextView {
    var rawString: String? { self.textStorage.string }
}
#elseif canImport(AppKit)
import AppKit
public extension NSTextView {
    var rawString: String? { self.textStorage?.string }
}
#endif

let paintItBlackTokenName = "paintItBlack"

public class LazyRTStyleTester {
    
    var tester: RT_StyleTester? = nil
    public init() {
        
    }
    public func setEditor(_ editor: RichTextView)  {
        self.tester = RT_StyleTester(editor)
    }
    
}

public class RT_StyleTester: NSObject {
    
    var textView: RichTextView
    var viewInterface: TextViewSystemInterface? = nil
    var highlighter: Highlighter? = nil
    
    var  mdParser: SymMarkdownParser? = nil
    
    public init(_ textView: RichTextView) {
        
        self.textView = textView
        
#if os(macOS)
guard let storage = textView.textStorage else {
    preconditionFailure("TextView's storage is nil")
}
#else
let storage = textView.textStorage
#endif

                
        let textProvider: TreeSitterClient.TextProvider = { range, _ in
            print("textProvider called range: \(range) \(storage.attributedSubstring(from: range).string)")
            
            return storage.attributedSubstring(from: range).string
        }

        
        super.init()
        
        var tokenProvider: TokenProvider = self.demoTokenProvider
        var attrProvider: TextViewSystemInterface.AttributeProvider = MarkdownStyles.getStylesFor
        
        let invalidationHandler: LanguageLayerTree.InvalidationHandler = { [weak self] in self?.handleInvalidation($0) }
        
        //md parsing
        let mdParse = try! SymMarkdownParser(invalidationHandler: invalidationHandler)
        
        if let tree = mdParse.tree {
            self.mdParser = mdParse
            tokenProvider = tree.tokenProvider(textProvider: textProvider)
        }
        
        self.textView.setTextStorageDelegate(delegate: self)
        let viewInterface = TextViewSystemInterface(textView: textView, 
                                                    attributeProvider: attrProvider
        )
        
        
        let highlighter = Highlighter(
            textInterface: viewInterface,
            tokenProvider: tokenProvider
                                      
        )
        self.viewInterface = viewInterface
        self.highlighter = highlighter
        
    }
    
    
    func demoAttributeProvider(_ token: Token) -> [NSAttributedString.Key: Any]? {
        print("Token: \(token.name)")
        
       if token.name == paintItBlackTokenName {
           return self.testAttr
       }
        
       return nil
    }
    
    
    var testAttr: [NSAttributedString.Key: Any] {
        
    #if canImport(UIKit)
            return [.foregroundColor: UIColor.red, .backgroundColor: UIColor.black]
    #elseif canImport(AppKit)
            return [.foregroundColor: NSColor.red, .backgroundColor: NSColor.black]
    #endif
    }
    
    
    func demoTokenProvider(_ range: NSRange, completionHandler: @escaping (Result<TokenApplication, Error>) -> Void) {
       var tokens: [Token] = []
       guard let searchString = self.textView.rawString else {
          // Could also complete with .failure(...) here
          completionHandler(.success(TokenApplication(tokens: tokens, action: .replace)))
          return
       }
       if let regex = try? NSRegularExpression(pattern: "[^\\s]+\\s{0,1}") {
          regex.enumerateMatches(in: searchString, range: range) { regexResult, _, _ in
             guard let result = regexResult else { return }
             for rangeIndex in 0..<result.numberOfRanges {
                let tokenRange = result.range(at: rangeIndex)
                tokens.append(Token(name: paintItBlackTokenName, range: tokenRange))
             }
          }
       }
       completionHandler(.success(TokenApplication(tokens: tokens, action: .replace)))
    }
    
    
    private func handleInvalidation(_ set: IndexSet) {
        print("handleInvalidation: \(set)")

        // here is where an HighlightInvalidationBuffer could be handy. Unfortunately,
        // a stock NSTextStorage/NSLayoutManager does not have sufficient callbacks
        // to know when it is safe to mutate the text style.
        DispatchQueue.main.async {
            self.highlighter?.invalidate(.set(set))
        }
    }

    /// Perform manual invalidation on the underlying highlighter
    public func invalidate(_ target: TextTarget = .all) {
        highlighter?.invalidate()
    }
    
}

extension RT_StyleTester: NSTextStorageDelegate {
    
    @available(iOS 14.0, *)
    public func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: TextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        print("will processEditing to : \(textStorage.string)")
//        self.mdParser?.tree?.willChangeContent(in: editedRange)
    }
    
    
#if canImport(UIKit)
    public func textStorage(_ textStorage: NSTextStorage,
                            didProcessEditing editedMask: NSTextStorage.EditActions,
                     range editedRange: NSRange, changeInLength delta: Int) {
        print("did processEditing to : \(textStorage.string)")
       // Map NSTextStorageDelegate editedRange to Neon's style of editedRange
//        guard let highlighter = self.highlighter else { return }
//        
//       let adjustedRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
//    
//        highlighter.didChangeContent(in: adjustedRange, delta: delta)
//
//       DispatchQueue.main.async {
//          highlighter.invalidate()
//       }
    }
#elseif canImport(AppKit)
    public func textStorage(_ textStorage: NSTextStorage,
                     didProcessEditing editedMask: NSTextStorageEditActions,
                     range editedRange: NSRange, changeInLength delta: Int) {
        print("didProcessEditing to : \(textStorage.string)")

       // Map NSTextStorageDelegate editedRange to Neon's style of editedRange
        guard let highlighter = self.highlighter else { return }
       let adjustedRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
        let string = textStorage.string
        
        
        highlighter.didChangeContent(in: adjustedRange, delta: delta)
        self.mdParser?.tree?.didChangeContent(to: string, in: adjustedRange, delta: delta, 
                                              limit: string.utf16.count)

        
//       DispatchQueue.main.async {
//          highlighter.invalidate()
//       }
    }
#endif
    
    
}
