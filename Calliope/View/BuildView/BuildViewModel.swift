//
//  BuildViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import Foundation

class BuildViewModel: ObservableObject {
    @Published var items: [BuildItem] = []
    @Published var showBuildItemSelection = false
        
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    private func fetchIndex(item: BuildItem) -> Int? {
        guard let index = items.firstIndex(where: {
            $0.id == item.id
        }) else {
            return nil
        }
        return index
    }
    
    func delete(item: BuildItem) {
        guard let index = fetchIndex(item: item) else {
            return
        }
        items.remove(at: index)
    }
    
    func update(item: BuildItem, object: BuildItem.BuildItemObject) {
        guard let index = fetchIndex(item: item) else {
            return
        }
        var nextItem = items[index]
        nextItem.object = object
        items[index] = nextItem
    }
    
    func save(){
        // TODO: saga を呼んで、PrintJobs形式にして保存する
    }
    
    
}
