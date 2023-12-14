//
//  ContentView.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationContext = NavigationContext()
    @State private var isEditorPresented = false
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List(selection: $navigationContext.selectedItem) {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        HStack {
                            Text(item.promptText)
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No prompts", systemImage: "pawprint")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                PromptView(item: nil)
            }
        } detail: {
            PromptView(item: navigationContext.selectedItem)
        }
    }

    private func addItem() {
        isEditorPresented = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
