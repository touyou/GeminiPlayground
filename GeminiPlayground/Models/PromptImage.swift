//
//  PromptImage.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI

enum TransferError: Error {
    case importFailed
}

struct PromptImage: Transferable {
    let image: Image
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
        #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(nsImage: nsImage)
            return PromptImage(image: image, data: data)
        #elseif canImport(UIKit)
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(uiImage: uiImage)
            return PromptImage(image: image, data: data)
        #else
            throw TransferError.importFailed
        #endif
        }
    }
}
