//
//  NavigationRouter.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

/**
 メインのナビゲーションルーター
 */
final class NavigationRouter: ObservableObject {
    @Published var items: [Item] = []
    
    static let shared = NavigationRouter()
    private init() {}
    
    enum Item: Hashable {
        case scan
        case build
    }
    
    func navigate(_ item: Item){
        items.append(item)
    }
    
    func goBack(){
        items.removeLast()
    }
    
    func goRoot(){
        items.removeAll()
    }
}
