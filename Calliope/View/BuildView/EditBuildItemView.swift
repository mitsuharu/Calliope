//
//  BuildItemDetailView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct EditBuildItemView: View {
    @EnvironmentObject var viewModel: BuildViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var item: BuildItem
    @State private var inputText: String = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            Text("EditBuildItemView \(item)")
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
            
            if case .image(let object) = item.object {
                if let image = object {
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
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage = newImage {
                viewModel.update(item: item, object: .image(object: newImage))
            }
        }
    }
}
