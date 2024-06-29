//
//  BuildView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct BuildView: View {
    @State private var items: [BuildItem] = []
    @State private var showBuildItemSelection = false
    @State private var itemSelection: BuildItem?
    
    var body: some View {
        List {
            if items.isEmpty {
                Section {
                    Text("右上の追加ボタンから印刷コマンドを追加してください")
                }
            }
            
            ForEach($items, id: \.uuid) { $item in
                BuildItemCell(item: $item) {
                    // スワイプ操作で削除コマンドを実行できる
                    if let index = items.firstIndex(where: {
                        $0.uuid == item.uuid
                    }) {
                        items.remove(at: index)
                    }
                }
         
            }
            .onMove(perform: move)
            
            if !items.isEmpty {
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
            BuildItemSelectionView(items: $items)
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

struct BuildItem {
    let uuid = UUID()
    var object: BuildItemObject
    
    enum BuildItemObject {
        case text(object: String?)
        case image(object: UIImage?)
        
        var description: String {
            switch self {
            case .text:
                return "文字を印刷する"
            case .image:
                return "画像を印刷する"
            }
        }
    }
    
    init(object: BuildItemObject) {
        self.object = object
    }
    
    init(itemJob: BuildItemJob) {
        switch itemJob {
        case .printText:
            self.init(object: .text(object: nil))
        case .printImage:
            self.init(object: .image(object: nil))
        }
    }
    
    enum BuildItemJob: CaseIterable {
        case printText
        case printImage
        
        var description: String {
            switch self {
            case .printText:
                return "文字を印刷する"
            case .printImage:
                return "画像を印刷する"
            }
        }
    }
    
    static func makeBuildItem(itemJob: BuildItemJob) -> BuildItem {
        switch itemJob {
        case .printText:
            return BuildItem(object: .text(object: nil))
        case .printImage:
            return BuildItem(object: .image(object: nil))
        }
    }
}

struct BuildItemSelectionView: View {
    @Binding var items: [BuildItem]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section("Select BuildItem") {
                ForEach(BuildItem.BuildItemJob.allCases, id: \.self) { itemJob in
                    ListCell(title: itemJob.description) {
                        items.append(BuildItem(itemJob: itemJob))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
