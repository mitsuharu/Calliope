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
    
    var body: some View {
        VStack {
            Text("MainView")
            Spacer().frame(height: 10)
            Text("name: \(viewModel.name ?? "-")")
            Spacer().frame(height: 10)
            Text("uuid: \(viewModel.uuid ?? "-")")
        }
    }
}

#Preview {
    MainView()
}
