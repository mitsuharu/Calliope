//
//  BuildItemCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct BuildItemCell: View {
    @EnvironmentObject var viewModel: BuildViewModel
    var item: BuildItem
    let deleteAction: (() -> Void)
    
    @State var text: String = ""
    @State var image: UIImage? = nil
    
    var body: some View {
        Component(
            item: item,
            text: $text,
            image: $image
        )
        .swipeActions {
            Button(role: .destructive) {
                deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }.onChange(of: text) { _, newValue in
            viewModel.update(item: item, object: .text(object: newValue))
        }.onChange(of: image) { _, newValue in
            if let newValue {
                viewModel.update(item: item, object: .image(object: newValue))
            }
        }
    }
}

extension BuildItemCell {
    
    fileprivate struct Component: View {
        var item: BuildItem
        
        @Binding var text: String
        @Binding var image: UIImage?
        @State private var showImagePicker = false
        
        var body: some View {
            if case .text(_) = item.object {
                TextComponent(item: item, text: $text)
            } else if case .image(_) = item.object {
                ImageComponent(item: item, image: $image)
            }
        }
    }
    
    fileprivate struct TextComponent: View {
        var item: BuildItem
        @Binding var text: String
        
        var body: some View {
            VStack{
                HStack {
                    Text(item.object.description).font(.system(.caption))
                    Spacer()
                }
                HStack{
                    if case .text(_) = item.object {
                        TextField("未設定です", text: $text)
                            .padding()
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.secondary, lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
        }
    }
    
    fileprivate struct ImageComponent: View {
        var item: BuildItem
        @Binding var image: UIImage?
        @State private var showImagePicker = false
        
        var body: some View {
            PlainCell(
                label: {
                    VStack{
                        HStack {
                            Text(item.object.description)
                                .font(.system(.caption))
                            Spacer()
                        }
                        HStack{
                            if let image {
                                Spacer()
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } else {
                                Text("未設定です").foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                },
                accessory: nil,
                action: {
                    showImagePicker.toggle()
                },
                deleteSwipeAction: nil
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(selectedImage: $image)
            }
            .onAppear {
                if case .image(let object) = item.object {
                    image = object
                }
            }
        }
    }
}

//#Preview {
//    BuildItemCell()
//}
