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

#if os(macOS)
import AppKit
import Foundation

extension NSFont {
    var bold: NSFont {
        return with(.bold)
    }

    var italic: NSFont {
        return with(.italic)
    }

    var boldItalic: NSFont {
        return with([.bold, .italic])
    }

    func with(_ traits: NSFontDescriptor.SymbolicTraits...) -> NSFont {
        let traitSet = NSFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)
        let descriptor: NSFontDescriptor = fontDescriptor.withSymbolicTraits(traitSet)
        return NSFont(descriptor: descriptor, size: 0) ?? self
    }

    func without(_ traits: NSFontDescriptor.SymbolicTraits...) -> NSFont {
        let traitSet = fontDescriptor.symbolicTraits.subtracting(NSFontDescriptor.SymbolicTraits(traits))
        let descriptor = fontDescriptor.withSymbolicTraits(traitSet)
        return NSFont(descriptor: descriptor, size: 0) ?? self
    }
}
#endif
