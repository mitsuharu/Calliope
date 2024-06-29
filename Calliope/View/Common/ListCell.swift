//
//  ListCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/22.
//

import SwiftUI

struct ListCell: View {
    let title: String
    let accessory: PlainCellAccessory?
    let action: (() -> Void)?
    let deleteSwipeAction: (() -> Void)?
    
    init(title: String, accessory: PlainCellAccessory? = nil, action: ( () -> Void)?, deleteSwipeAction: ( () -> Void)? = nil) {
        self.title = title
        self.accessory = accessory
        self.action = action
        self.deleteSwipeAction = deleteSwipeAction
    }
        
    var body: some View {
        PlainCell(
            label: {
                Text(title)
            },
            accessory: accessory,
            action: action,
            deleteSwipeAction: deleteSwipeAction
        )
    }
}



//V
