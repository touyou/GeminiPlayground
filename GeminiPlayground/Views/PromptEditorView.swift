//
//  PromptEditorView.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI

struct PromptEditorView: View {
    private let gemini = Gemini.shared
    var item: Item?
    
    @State private var prompt: String = ""
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
                    TextField("Enter Prompt", text: $prompt)
                    Text(response ?? "No Response")
                        .foregroundStyle(response?.isEmpty == false ? .primary : .tertiary)
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
                    response = try await gemini.execute(prompt: prompt, images: [])
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
            item.responseText = response
        } else {
            let newItem = Item(timestamp: Date.now, promptText: prompt, promptImages: [], responseText: response)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    PromptEditorView(item: nil)
}
