//
//  ContentView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = NavigationRouter()
    
    var body: some View {
        NavigationStack(path: $router.items) {
            MainView()
                .navigationTitle("印刷アプリ")
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            router.navigate(.scan)
                        }) {
                            Label("scan", systemImage: "plus.viewfinder")
                        }
                    }
                }
                .modifier(NavigationModifier())
                .modifier(ToastModifier())
        }
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}
