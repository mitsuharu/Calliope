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
    
    var selectedIndex: Int = 0
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(item: BuildItem) {
        guard let index = items.firstIndex(where: {
            $0.id == item.id
        }) else {
            return
        }
        
        items.remove(at: index)
    }
    
    func update(item: BuildItem, object: BuildItem.BuildItemObject) {
        guard let index = items.firstIndex(where: {
            $0.id == item.id
        }) else {
            return
        }
        
        var nextItem = items[index]
        nextItem.object = object
        items[index] = nextItem
    }
    
    
}
