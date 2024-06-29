//
//  ListCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/22.
//

import SwiftUI

struct ListCell: View {
    let title: String
    let accessory: Accessory?
    let action: (() -> Void)?
    let deleteSwipeAction: (() -> Void)?
    
    init(title: String, accessory: Accessory? = nil, action: ( () -> Void)?, deleteSwipeAction: ( () -> Void)? = nil) {
        self.title = title
        self.accessory = accessory
        self.action = action
        self.deleteSwipeAction = deleteSwipeAction
    }
        
    var body: some View {
        Button {
            action?()
        } label: {
            HStack{
                Text(title).tint(.black)
                Spacer()
                AccessoryView(accessory: accessory)
            }
            .contentShape(Rectangle())
        }
        .modifier(SwipeActionsModifier(type: .delete, action: deleteSwipeAction))
    }
}

extension ListCell {
    
    enum Accessory {
        case disclosureIndicator
    }
    
    fileprivate struct AccessoryView: View {
        let accessory: Accessory?
        var body: some View {
            switch accessory {
            case .disclosureIndicator:
                Image(systemName: "chevron.right").tint(.gray)
            default:
                EmptyView()
            }
        }
    }
}

extension ListCell {
    
    enum SwipeActionType {
        case delete
    }
    
    fileprivate struct SwipeActionsModifier: ViewModifier {
        let type: SwipeActionType?
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
    
}

#Preview {
    ListCell(title: "title", accessory: nil) {
        print("tap")
    } deleteSwipeAction: {
        print("delete")
    }

}
