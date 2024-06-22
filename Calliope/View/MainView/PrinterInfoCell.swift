//
//  PrinterInfoCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/22.
//

import SwiftUI

struct PrinterInfoCell: View {
    let title: String
    let detail: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(.caption))
            Spacer().frame(height: 4)
            Text(detail ?? "-")
                .font(.system(.body))
        }
    }
}

#Preview {
    PrinterInfoCell(title: "タイトル", detail: "中身です")
}
