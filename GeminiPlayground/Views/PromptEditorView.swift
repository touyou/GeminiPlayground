//
//  PromptEditorView.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI
import GoogleGenerativeAI

struct PromptEditorView: View {
    private let gemini = Gemini.shared
    
    var item: Item?
    var promptSize: Double {
        Data(prompt.utf8).megabytes + promptImages.reduce(0, { $0 + $1.megabytes })
    }
    
    @State private var prompt: String = ""
    @State private var promptImages: [Data] = []
    @State private var response: String?
    @State private var trigger: Bool?
    @State private var isLoading: Bool = false
    @State private var isPresentingAlert: Bool = false
    @State private var errorAlertText: String?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Prompt") {
                        ImageCarousel(promptImages: $promptImages, isEditable: true)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.none)
                    }
                    Section {
                        TextField("Enter Prompt", text: $prompt)
                        HStack {
                            Text("Prompt size: \(String(format: "%.2f", promptSize))")
                            Spacer()
                            if promptSize > 4.0 {
                                Label("NG(over 4MB)", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.red)
                            } else {
                                Label("OK(under 4MB)", systemImage: "checkmark.seal.fill")
                                    .foregroundStyle(Color.teal)
                            }
                        }
                        .font(.caption)
                    }
                    Section("Result") {
                        Text(response ?? "No Response")
                            .foregroundStyle(response?.isEmpty == false ? .primary : .tertiary)
                    }
                }
                .clipShape(RoundedRectangle(cornerSize: .init(width: 8.0, height: 8.0)))
                Button(action: {
                    if trigger == nil {
                        trigger = true
                    } else {
                        trigger?.toggle()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(response?.isEmpty == false ? "Re-Generate" : "Generate")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                    .disabled($response.wrappedValue == nil)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .task(id: trigger) {
                guard trigger != nil else { return }
                isLoading = true
                do {
                    response = try await gemini.execute(prompt: prompt, images: promptImages)
                } catch let error as GenerateContentError {
                    isPresentingAlert = true
                    switch error {
                    case let .internalError(internalError):
                        errorAlertText = "\(internalError)"
                    case let .promptBlocked(response):
                        errorAlertText = "block prompt: \(response.promptFeedback?.blockReason?.rawValue ?? "unkonwn reason")"
                    case let .responseStoppedEarly(reason, response):
                        errorAlertText = "response stopped early: \(reason) / \(response.promptFeedback?.blockReason?.rawValue ?? "unknown reason")"
                    }
                    print("error: ", error)
                } catch let error {
                    isPresentingAlert = true
                    errorAlertText = error.localizedDescription
                }
                isLoading = false
            }
            .onAppear {
                if let item {
                    prompt = item.promptText
                    response = item.responseText
                }
            }
            .alert("Error", isPresented: $isPresentingAlert) {
                Button("OK") {
                    errorAlertText = nil
                }
            }
        }
    }
    
    private func save() {
        if let item {
            item.promptText = prompt
            item.promptImages = promptImages
            item.responseText = response
        } else {
            let newItem = Item(timestamp: Date.now, promptText: prompt, promptImages: promptImages, responseText: response)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    PromptEditorView(item: nil)
}
