//
//  BuildView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct BuildView: View {
    
    @State private var showBuildItemSelection = false
    
//    @ObservedObject var viewModel = BuildViewModel()
    @EnvironmentObject var viewModel: BuildViewModel
    
    var body: some View {
        List {
            if viewModel.items.isEmpty {
                Section {
                    Text("右上の追加ボタンから印刷コマンドを追加してください")
                }
            }
            
            ForEach(viewModel.items, id: \.id) { item in
                BuildItemCell(item: item) {
                    NavigationRouter.shared.navigate(.editItem(item: item))
                } deleteAction: {
                    viewModel.delete(item: item)
                }

    
                
               
//                BuildItemCell(item: item) {
//                    // スワイプ操作で削除コマンドを実行できる
//                    if let index = items.firstIndex(where: {
//                        $0.uuid == item.uuid
//                    }) {
//                        items.remove(at: index)
//                    }
//                }
         
            }
            .onMove(perform: move)
            
            if !viewModel.items.isEmpty {
                Section {
                    ListCell(title: "保存する") {
                        print("保存する")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    EditButton()
                    Button(action: {
                        showBuildItemSelection.toggle()
                    }) {
                        Text("追加")
                    }
                }
            }
        }
        .sheet(isPresented: $showBuildItemSelection) {
            BuildItemSelectionView()
        }
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

//import SwiftUI
//
//struct BuildView: View {
//    var body: some View {
//        Text("BuildView")
//    }
//}
//
//#Preview {
//    BuildView()
//}
