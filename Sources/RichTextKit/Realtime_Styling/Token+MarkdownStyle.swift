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

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif

var uniqueTokenNames = Set<String>()

public class MarkdownStyles {
    
    
    
    public static func applyTokenStyles(token: Token,
                                        sourceText: String?) -> [NSAttributedString.Key: Any]? {
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        
        // Iterate through all rules
//        for rule in rules {
//            if rule.tokenName == token.name {
//                for formattingRule in rule.formattingRules {
//                    if let key = formattingRule.key {
//                        let tokenString = sourceText != nil ? (sourceText! as NSString).substring(with: token.range) : ""
//                        let value = formattingRule.calculateValue?(tokenString, token.range) ?? ""
//                        attributes[key] = value
//                    }
//                }
//            }
//        }
        
        return attributes.isEmpty ? nil : attributes
    }
    

    
    public static func getStylesFor(_ token: Token) -> [NSAttributedString.Key: Any]? {
//        print("Token: \(token.name)")
        
        let uniqueCount_Pre = uniqueTokenNames.count
        
        uniqueTokenNames.insert(token.name)
        
        let uniqueCount_Post = uniqueTokenNames.count
        if (uniqueCount_Post > uniqueCount_Pre) {
            print("New Unique Token \(uniqueCount_Post): \(token.name)")
        }
        
        var styles = [NSAttributedString.Key: Any]()
        
        let editorFont = defaultEditorFont
        let editorTextColor = defaultEditorTextColor

        styles[.font] = editorFont
        styles[.foregroundColor] = editorTextColor
        return styles
        
    }
    
}
