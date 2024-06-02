//
//  DoPrintCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import SwiftUI

struct DoPrintCell: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .padding()
            .background(Color.secondary, in: RoundedRectangle(cornerRadius: 16))
            .padding().aspectRatio(1.0, contentMode: .fill)
    }
}

#Preview {
    DoPrintCell(title: "タイトルです")
}
