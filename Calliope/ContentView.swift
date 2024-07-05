//
//  ContentView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var router = NavigationRouter.shared
    
    private func navigateAppSettings() {
        if 
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) 
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    var body: some View {
        NavigationStack(path: $router.items) {
            MainView()
                .navigationTitle("App_Home")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            navigateAppSettings()
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
        }
        .modifier(ToastModifier())
        .modifier(LoadingModifier())
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}
