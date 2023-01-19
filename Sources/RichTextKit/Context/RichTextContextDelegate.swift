//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 1/19/23.
//

import Foundation


public protocol RichTextContextDelegate {

    func shouldOverridePasteHandling() -> Bool
    
    func handlePastedImages(images: [ImageRepresentable]) -> Void
    
    func shouldOverrideDropHandling() -> Bool
    func handleDroppedImages(images: [ImageRepresentable]) -> Void
}

