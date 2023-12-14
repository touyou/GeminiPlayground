//
//  ImageCarousel.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import SwiftUI
import PhotosUI

struct ImageCarousel: View {
    @State var selectedItems: [PhotosPickerItem] = []
    @State var selectedImages: [Image] = []
    
    @Binding var promptImages: [Data]
    
    let isEditable: Bool
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(0..<selectedImages.count, id: \.self) { i in
                        selectedImages[i]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                            .padding(.horizontal, 10)
                }
                if isEditable {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 16, matching: .images, preferredItemEncoding: .compatible, photoLibrary: .shared()) {
                        Label("Add", systemImage: "photo.badge.plus")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .padding(.horizontal, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, idealHeight: 120)
        .onAppear {
            selectedImages = promptImages.compactMap {
                if let uiImage = UIImage(data: $0) {
                    return Image(uiImage: uiImage)
                }
                return nil
            }
        }
        .onChange(of: selectedItems) {
            Task {
                selectedImages.removeAll()
                
                var datas = [Data]()
                for item in selectedItems {
                    if let imageData = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: imageData),
                       let compressionData = uiImage.jpegData(compressionQuality: 0.25) {
                        selectedImages.append(Image(uiImage: uiImage))
                        datas.append(compressionData)
                    }
                }
                promptImages = datas
            }
        }
    }
}
