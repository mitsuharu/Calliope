//
//  BuildItem.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import Foundation

struct BuildItem: Identifiable, Hashable {
    let id = UUID()
    
    static func == (lhs: BuildItem, rhs: BuildItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
