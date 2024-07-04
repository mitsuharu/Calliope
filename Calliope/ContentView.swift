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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            router.navigate(.license)
                        }) {
                            Image(systemName: "gearshape")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            router.navigate(.scan)
                        }) {
                            Image(systemName: "plus.viewfinder")
                        }
                    }
                }
                .modifier(NavigationModifier())
                .modifier(ToastModifier())
                .modifier(LoadingModifier())
        }
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}
