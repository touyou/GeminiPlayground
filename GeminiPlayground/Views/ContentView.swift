//
//  ContentView.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var navigationContext = NavigationContext()

    var body: some View {
        NavigationSplitView {
            PromptList()
        } detail: {
            NavigationStack {
                PromptView(item: navigationContext.selectedItem)
            }
        }
        .environment(navigationContext)
    }
}

private struct PromptList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationContext.self) private var navigationContext
    
    @State private var isEditorPresented = false
    
    @Query private var items: [Item]

    
    var body: some View {
        @Bindable var navigationContext = navigationContext
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
            PromptEditorView(item: nil)
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
