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
 
    private var isRegular: Bool {
        if case .regular = viewModel.type {
            return true
        } else {
            return false
        }
    }

    private var backgroundColor: Color {
        if case .error = viewModel.type {
            return .red
        }
        return .gray
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $viewModel.showToast, duration: isRegular ? 3.0 : 4.0, tapToDismiss: true) {
                let style = AlertToast.AlertStyle.style(
                    backgroundColor: backgroundColor,
                    titleColor: .white,
                    subTitleColor: nil,
                    titleFont: nil,
                    subTitleFont: nil
                )
                let alert = AlertToast(
                    displayMode: .alert, // .banner(.pop),
                    type: .regular,
                    title: viewModel.message,
                    subTitle: viewModel.subMessage,
                    style: style
                )
                return alert
            }
    }
}
