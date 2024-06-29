//
//  NavigationModifier.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import SwiftUI

/**
 NavigationRouter に対応するルーティング制御
 */
struct NavigationModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationRouter.Item.self) {
                switch $0 {
                case .scan:
                    ScanView().navigationTitle("scan")
                case .build:
                    BuildView().navigationTitle("build print jobs")
                }
            }
    }
}
