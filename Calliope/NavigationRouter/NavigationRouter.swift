//
//  NavigationRouter.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

final class NavigationRouter: ObservableObject {
    @Published var items: [Item] = []
    
    enum Item: Hashable {
      case scan
    }
    
    func navigate(_ item: Item){
        items.append(item)
    }
    
    func goBack(_ item: Item){
        items.removeLast()
    }
    
    func goRoot(_ item: Item){
        items.removeAll()
    }
}
