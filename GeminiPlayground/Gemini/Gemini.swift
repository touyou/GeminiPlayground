//
//  Gemini.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import GoogleGenerativeAI
import UIKit

final class Gemini {
    static let shared = Gemini()
    
    func generatePrompts(prompt: String, images: [Data]) -> [PartsRepresentable] {
        return [prompt] + images.compactMap { UIImage(data: $0) }
    }
    
    func execute(prompt: String, images: [Data]) async throws -> String? {
        return try await execute(generatePrompts(prompt: prompt, images: images), hasImage: !images.isEmpty)
    }
    
    func execute(_ parts: PartsRepresentable..., hasImage: Bool) async throws -> String? {
       return try await execute(parts, hasImage: hasImage)
    }
    
    func execute(_ parts: [PartsRepresentable], hasImage: Bool) async throws -> String? {
        let modelName = hasImage ? "gemini-pro-vision" : "gemini-pro"
        let model = GenerativeModel(name: modelName, apiKey: GeminiAPIKey.default)
        let response = try await model.generateContent(parts)
        return response.text
    }
}
