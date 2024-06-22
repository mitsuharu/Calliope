//
//  CandiateCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import SwiftUI

struct CandiateCell: View {
    @Binding var deviceInfo: PrinterDeviceInfo
    
    var body: some View {
        HStack{
            Component(
                manufacturer: deviceInfo.manufacturer.name,
                name: deviceInfo.name,
                uuid: deviceInfo.uuid
            )
            Spacer()
        }
    }
}

extension CandiateCell {
    fileprivate struct Component: View {
        var manufacturer: String
        var name: String?
        var uuid: String
        
        var body: some View {
            VStack(alignment: .leading) {
//                Text(manufacturer)
//                Spacer().frame(height: 10)
                HStack(alignment: .center)  {
                    Text("name: ").frame(width: 50, alignment: .leading)
                    Text(name ?? "-")
                }
                Spacer().frame(height: 10)
                HStack(alignment: .center) {
                    Text("uuid: ").frame(width: 50, alignment: .leading)
                    Text(uuid)
                }
            }
        }
    }
}

#Preview {
    CandiateCell.Component(
        manufacturer: "EPSON",
        name: "機器の名前",
        uuid: "8F0FF315-E626-642D-4898-A78A6A1E3B5D"
    )
}
