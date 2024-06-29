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
            Text(detail ?? "未選択です")
                .font(.system(.body))
                .foregroundStyle((detail == nil) ? .secondary : .primary)
        }
    }
}

#Preview {
    PrinterInfoCell(title: "タイトル", detail: "中身です")
}
