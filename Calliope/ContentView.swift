//
//  ContentView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import SwiftUI

struct ContentView: View {
    
    let printerUseCase = PrinterUseCase()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear(){
            printerUseCase.run()
        }
    }
}

#Preview {
    ContentView()
}
