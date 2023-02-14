//
//  RichTextEditor.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-21.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(tvOS)
import SwiftUI

/**
 This SwiftUI text editor can be used to edit rich text with
 an embedded ``RichTextView``, a ``RichTextContext`` as well
 as a ``RichTextCoordinator``.

 When you create an editor, you just have to provide it with
 a rich text context. The editor will then set up everything
 so that you only have to use the context to observe changes
 and trigger changes in the editor.
 */
public struct RichTextEditor: ViewRepresentable {

    /**
     Create a rich text editor with a certain text that uses
     a certain rich text data format.

     - Parameters:
       - text: The rich text to edit.
       - context: The rich text context to use.
       - format: The rich text data format, by default ``RichTextDataFormat/archivedData``.
     */
    public init(
        text: Binding<NSAttributedString>,
        context: RichTextContext,
        format: RichTextDataFormat = .archivedData,
        maxHeight: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        textStorage: NSTextStorage? = nil,
        viewConfiguration: @escaping ViewConfiguration = { _ in }
    ) {
        self.text = text
        self._richTextContext = ObservedObject(wrappedValue: context)
        self.format = format
        self.configuredMinHeight = minHeight
        self.configuredMaxHeight = maxHeight
        self.explicitTextStorage = textStorage
        self.viewConfiguration = viewConfiguration
    }

    public typealias ViewConfiguration = (RichTextViewComponent) -> Void

    private(set) var configuredMaxHeight: CGFloat?
    private(set) var configuredMinHeight: CGFloat?
    private(set) var explicitTextStorage: NSTextStorage?
    
    private var format: RichTextDataFormat
    
    private var text: Binding<NSAttributedString>

    @ObservedObject
    private var richTextContext: RichTextContext

    private var viewConfiguration: ViewConfiguration


    #if os(iOS) || os(tvOS)
    public let textView = RichTextView()
    #endif

    #if os(macOS)
    public let scrollView = RichTextView.scrollableTextView()
    public var textView: RichTextView {
        scrollView.documentView as? RichTextView ?? RichTextView()
    }
    #endif


    public func makeCoordinator() -> RichTextCoordinator {
        RichTextCoordinator(
            text: text,
            textView: textView,
            richTextContext: richTextContext
        )
    }


    #if os(iOS) || os(tvOS)
    public func makeUIView(context: Context) -> RichTextView {
        textView.setup(with: text.wrappedValue, format: format)
        if let mHeight = self.configuredMaxHeight {
            textView.maxHeight = mHeight
        }
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.keyboardDismissMode = .interactive
        textView.textContainerInset = UIEdgeInsets.zero
        textView.insetsLayoutMarginsFromSafeArea = false
        
        viewConfiguration(textView)
        return textView
    }

    public func updateUIView(_ view: RichTextView, context: Context) {
    }
    #endif

    #if os(macOS)
    public func makeNSView(context: Context) -> some NSView {
        textView.setupForDynamicHeight(with: text.wrappedValue,
                                    format: format,
                                    scrollView: scrollView,
                                       maxHeight: self.configuredMaxHeight,
                                       minHeight: self.configuredMinHeight)
        
        textView.autoresizingMask = [.height, .width]
        scrollView.autoresizingMask = [.height, .width]

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        
        //Autogrowing implementation
        
        //https://stackoverflow.com/questions/63127103/how-to-auto-expand-height-of-nstextview-in-swiftui
        //alternative: https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0
        
        
        
        textView.textContentInset = CGSize(width: 8, height: 8)
        
        scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
//        scrollView.backgroundColor = .yellow
        
        viewConfiguration(textView)
        return scrollView
    }
    
    public func updateNSView(_ view: NSViewType, context: Context) {
        
    }
    
    #endif
}


// MARK: RichTextPresenter

public extension RichTextEditor {

    /**
     Get the currently selected range.
     */
    var selectedRange: NSRange {
        textView.selectedRange
    }
}


// MARK: RichTextReader

public extension RichTextEditor {

    /**
     Get the rich text that is managed by the editor.
     */
    var attributedString: NSAttributedString {
        text.wrappedValue
    }
}


// MARK: RichTextWriter

public extension RichTextEditor {

    /**
     Get the mutable rich text that is managed by the editor.
     */
    var mutableAttributedString: NSMutableAttributedString? {
        textView.mutableAttributedString
    }
}

#endif
