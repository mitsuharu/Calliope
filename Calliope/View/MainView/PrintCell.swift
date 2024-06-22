//
//  PrintCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/22.
//

import SwiftUI

struct PrintCell: View {
    let title: String
    
    var body: some View {
        Component(title: title)
    }
}

extension PrintCell {
    fileprivate struct Component: View {
        var title: String
        var body: some View {
            Text(title)
        }
    }
}

#Preview {
    PrintCell.Component(
        title: "EPSON"
    )
}
