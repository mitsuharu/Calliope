//
//  PrinterInfoCell.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/22.
//

import SwiftUI

struct PrinterInfoCell: View {
    
    enum DataSource {
        case regular(name: String?, uuid: String?)
        case deviceInfo(item: PrinterDeviceInfo)
    }
    
    let dataSource: DataSource
    
    init(name: String?, uuid: String?) {
        self.dataSource = .regular(name: name, uuid: uuid)
    }
    
    init(deviceInfo: PrinterDeviceInfo) {
        self.dataSource = .deviceInfo(item: deviceInfo)
    }
    
    var body: some View {
        if case .deviceInfo(let item) = dataSource {
            ComponentV(manufacturer: nil, name: item.name, uuid: item.uuid)
        } else if case .regular(let name, let uuid) = dataSource {
            if let uuid {
                ComponentV(manufacturer: nil, name: name, uuid: uuid)
            } else {
                UnsetComponent()
            }
        }
    }
}

//struct CandiateCell2: View {
//    var deviceInfo: PrinterDeviceInfo
//    
//    var body: some View {
//        HStack{
//            Component(
//                manufacturer: deviceInfo.manufacturer.name,
//                name: deviceInfo.name,
//                uuid: deviceInfo.uuid
//            )
//            Spacer()
//        }
//    }
//}


extension PrinterInfoCell {
    
    struct ComponentV: View {
        var manufacturer: String?
        var name: String?
        var uuid: String
        
        var body: some View {
            VStack(alignment: .leading) {
                if let manufacturer {
                    Text(manufacturer)
                    Spacer().frame(height: 10)
                    Spacer().frame(height: 8)
                }
                VStack(alignment: .leading) {
                    Text("NAME")
                        .frame(alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(name ?? "no name")
                }
                Spacer().frame(height: 8)
                VStack(alignment: .leading) {
                    Text("UUID")
                        .frame(alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(uuid)
                }
            }
        }
    }
    
    struct ComponentH: View {
        var manufacturer: String?
        var name: String?
        var uuid: String
        private let titleWidth = 50.0
        
        var body: some View {
            VStack(alignment: .leading) {
                if let manufacturer {
                    Text(manufacturer)
                    Spacer().frame(height: 10)
                    Spacer().frame(height: 8)
                }
                HStack(alignment: .center)  {
                    Text("NAME")
                        .frame(width: titleWidth, alignment: .trailing)
                        .foregroundColor(.secondary)
                    Text(name ?? "no name")
                }.frame(minHeight: 20)
                Spacer().frame(height: 8)
                HStack(alignment: .center) {
                    Text("UUID")
                        .frame(width: titleWidth, alignment: .trailing)
                        .foregroundColor(.secondary)
                    Text(uuid)
                }.frame(minHeight: 20)
            }
        }
    }
    
    struct UnsetComponent: View {
        var body: some View {
            VStack{
                HStack {
                    Text("未選択です")
                        .font(.system(.body))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack {
                    Text("右上のスキャンボタンからプリンターを探してください")
                        .font(.system(.caption))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
    }
    
}

#Preview {
    PrinterInfoCell.ComponentH(name: "Hello World", uuid: "abcd-1234")
}
