//
//  ToastModifier.swift
//  Example
//
//  Created by Mitsuharu Emoto on 2023/09/16.
//

import SwiftUI
import AlertToast

struct ToastModifier: ViewModifier {
    
    @ObservedObject private var viewModel = ToastViewModel.shared
 
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $viewModel.showToast) {
                AlertToast(type: .regular, title: viewModel.message)
            }
    }
}
