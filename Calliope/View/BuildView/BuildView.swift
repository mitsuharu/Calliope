//
//  BuildView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

/**
 印刷コマンドをビルドする
 
 @note
 このViewはビルド特化で、他の画面とは独立している
 */
struct BuildView: View {
    
    @State private var showAddBuildItemView = false
    
    // BuildView関連でenvironmentObjectで渡す
    @ObservedObject var viewModel = BuildViewModel()

    
    var body: some View {
        List {
            if viewModel.items.isEmpty {
                Section {
                    Text("右上の追加ボタンから印刷コマンドを追加してください")
                }
            }
            
            ForEach(viewModel.items, id: \.id) { item in
                BuildItemCell(item: item) {
                    viewModel.delete(item: item)
                }
            }
            .onMove(perform: move)
            
            if !viewModel.items.isEmpty {
                Section {
                    ListCell(title: "保存する") {
                        viewModel.save()
                        NavigationRouter.shared.goBack()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    EditButton()
                    Button(action: {
                        showAddBuildItemView.toggle()
                    }) {
                        Text("追加")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddBuildItemView) {
            AddBuildItemView()
        }.environmentObject(viewModel)
    }

    private func move(from source: IndexSet, to destination: Int) {
        viewModel.move(from: source, to: destination)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//#Preview {
//    BuildView()
//}
