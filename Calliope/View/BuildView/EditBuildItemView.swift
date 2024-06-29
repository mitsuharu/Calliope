//
//  BuildItemDetailView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct EditBuildItemView: View {
    @Binding var item: BuildItem
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
                    .onChange(of: inputText) { newValue in
                        item.object = .text(object: newValue)
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
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage {
                item.object = .image(object: newImage)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
