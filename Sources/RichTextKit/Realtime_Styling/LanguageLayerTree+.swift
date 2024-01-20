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
import Neon
import TreeSitterClient


public extension LanguageLayerTree {
    /// Produce a `TokenProvider` function for use with `Highlighter`.
    func tokenProvider(textProvider: LanguageLayerTree.TextProvider? = nil) -> TokenProvider {
        return { [weak self] range, completionHandler in
            guard let self = self else {
                completionHandler(.failure(TreeSitterClientError.stateInvalid))
                return
            }
            do {
                print("Token Provider for range: \(range)")
//                let membershipProvider: SwiftTreeSitter.Predicate.GroupMembershipProvider = { query, range, _ in
//                    guard query == "local" else { return false }
//                    return false
//                }
//                let context = SwiftTreeSitter.Predicate.Context(
//                    textProvider: source.cursorTextProvider,
//                    groupMembershipProvider: membershipProvider
//                )
//                
                
                let highlightedRanges = try self.highlights(in: range)
                let tokens = highlightedRanges.map { Token(name: $0.name, range: $0.range) }
                let tokenApp = TokenApplication(tokens: tokens)

                completionHandler(.success(tokenApp))
            } catch {
                completionHandler(.failure(TreeSitterClientError.stateInvalid))
                return
            }
            
        }
    }
    
    
}
