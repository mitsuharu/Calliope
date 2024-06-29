//
//  PlainCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

enum PlainCellAccessory {
    case disclosureIndicator
}

enum PlainCellSwipeActionType {
    case delete
}

struct PlainCell<Content: View>: View {
    
    @ViewBuilder var label: () -> Content
    let accessory: PlainCellAccessory?
    let action: (() -> Void)?
    let deleteSwipeAction: (() -> Void)?
        
    init(label: @escaping () -> Content, accessory: PlainCellAccessory?, action: ( () -> Void)?, deleteSwipeAction: ( () -> Void)?) {
        self.label = label
        self.accessory = accessory
        self.action = action
        self.deleteSwipeAction = deleteSwipeAction
    }
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack{
                label().tint(.black)
                Spacer()
                AccessoryView(accessory: accessory)
            }
            .contentShape(Rectangle())
        }
        .modifier(SwipeActionsModifier(type: .delete, action: deleteSwipeAction))
    }
    
}

fileprivate struct AccessoryView: View {
    let accessory: PlainCellAccessory?
    var body: some View {
        switch accessory {
        case .disclosureIndicator:
            Image(systemName: "chevron.right").tint(.gray)
        default:
            EmptyView()
        }
    }
}

fileprivate struct SwipeActionsModifier: ViewModifier {
    let type: PlainCellSwipeActionType?
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        if let type, let action {
            content
                .swipeActions {
                    Button(role: .destructive) {
                        action()
                    } label: {
                        switch type {
                        case .delete:
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
        } else {
            content
        }
    }
}
