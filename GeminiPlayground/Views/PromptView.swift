//
//  PromptView.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI

struct PromptView: View {
    var item: Item?
    
    @State private var isEditing = false
    
    var body: some View {
        if let item {
            ScrollView {
                VStack(alignment: .leading, spacing: 16.0) {
                    Text(item.promptText)
                        .foregroundStyle(.primary)
                        .bold()
                        .frame(maxWidth: .infinity)
                    Text(item.responseText ?? "No response")
                        .foregroundStyle(item.responseText?.isEmpty == false ? .primary : .tertiary)
                        .frame(maxWidth: .infinity)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .toolbar {
                Button { isEditing = true } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            .sheet(isPresented: $isEditing) {
                PromptEditorView(item: item)
            }
        } else {
            ContentUnavailableView("Invalid Data", systemImage: "pawprint")
        }
    }
}

#Preview {
    PromptView()
}
