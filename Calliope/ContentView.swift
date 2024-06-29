//
//  ContentView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var router = NavigationRouter.shared
    
    var body: some View {
        NavigationStack(path: $router.items) {
            MainView()
                .navigationTitle("App_Home")
                .navigationBarTitleDisplayMode(.inline)
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
