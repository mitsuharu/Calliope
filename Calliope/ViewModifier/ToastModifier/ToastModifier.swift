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
            .toast(isPresenting: $viewModel.showToast, duration: 3.0, tapToDismiss: true) {
                let style = AlertToast.AlertStyle.style(
                    backgroundColor: .secondary,
                    titleColor: .primary,
                    subTitleColor: nil,
                    titleFont: nil,
                    subTitleFont: nil
                )
                let alert = AlertToast(
                    displayMode:.banner(.pop),
                    type: .regular,
                    title: viewModel.message,
                    style: style
                )
                return alert
            }
    }
}
