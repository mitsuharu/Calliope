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
    
    var body: some View {
        NavigationLink(
            // ここでenvironmentObjectを再設定しないと伝播しない
            destination: EditBuildItemView(item: item).environmentObject(viewModel)
        ) {
            Component(item: item)
        }
        .swipeActions {
            Button(role: .destructive) {
                deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension BuildItemCell {
    
    struct Component: View {
        var item: BuildItem
        
        var body: some View {
            VStack{
                HStack {
                    Text(item.object.description).font(.system(.caption))
                    Spacer()
                }
                HStack{
                    if case .text(let object) = item.object {
                        if let text = object {
                            Text(text)
                        } else {
                            Text("未設定です").foregroundColor(.gray)
                        }
                    }
                    if case .image(let object) = item.object {
                        if let image = object {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        } else {
                            Text("未設定です").foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

//#Preview {
//    BuildItemCell()
//}
