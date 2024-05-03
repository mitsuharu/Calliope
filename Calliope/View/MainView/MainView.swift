//
//  MainView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import SwiftUI

struct MainView: View {
    let printerUseCase = PrinterUseCase()
    
    var body: some View {
        Text("MainView")
            .onAppear(){
//                printerUseCase.run()
            }
    }
}

#Preview {
    MainView()
}
