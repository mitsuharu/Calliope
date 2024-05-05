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
                    ForEach((0..<8), id: \.self) { _ in
                        Button(action: {
                            let orders: [PrinterOrder] = [
                                .text(text: "hello"),
                                .text(text: "こんにちはコンニチワ今日わ"),
                                .feed(count: 1),
                                .qrCode(text: "http://www.example.com")]
                            appStore.dispatch(onMain: RunPrinterOrder(orders: orders))
                        }) {
                            DoPrintCell()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
