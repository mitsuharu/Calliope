//
//  MainView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel = MainViewModel()
//    let printerUseCase = PrinterUseCase()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()),
                                            count: 2)
    
    var body: some View {
        VStack {
            VStack{
                Text("name: \(viewModel.name ?? "-")")
                Spacer().frame(height: 10)
                Text("uuid: \(viewModel.uuid ?? "-")")
            }.padding()
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.sampleCommonds, id: \.uuid) { item in
                        Button {
                            item.action()
                        } label: {
                            DoPrintCell(title: item.title)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
