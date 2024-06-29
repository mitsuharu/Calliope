//
//  BuildItemDetailView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct EditBuildItemView: View {
    @EnvironmentObject var viewModel: BuildViewModel
    
    var item: BuildItem
    @State private var inputText: String = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            if case .text(let object ) = item.object {
                Text("Write text")
                TextField("", text: $inputText)
                    .onAppear {
                        inputText = object ?? ""
                    }
                    .onChange(of: inputText) { _, newValue in
                        viewModel.update(item: item, object: .text(object: newValue))
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            if case .image(_) = item.object {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Text("Select Image")
                }
                .padding()
            }
        }
        .navigationTitle(item.object.description)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .onAppear {
            if case .image(let object) = item.object {
                selectedImage = object
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage {
                viewModel.update(item: item, object: .image(object: newImage))
            }
        }
    }
}
