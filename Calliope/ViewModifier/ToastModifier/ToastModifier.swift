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
    
    private var duration: Double {
        if case .loading = viewModel.type {
            return 0
        }
        return isRegular ? 3.0 : 4.0
    }
    
    private var type: AlertToast.AlertType {
        if case .loading = viewModel.type {
            return .loading
        }
        return .regular
    }
    
    private var backgroundColor: Color {
        if case .error = viewModel.type {
            return .red
        }
        return .gray
    }
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $viewModel.showToast, duration: duration, tapToDismiss: true) {
                let style = AlertToast.AlertStyle.style(
                    backgroundColor: backgroundColor,
                    titleColor: .white,
                    subTitleColor: nil,
                    titleFont: nil,
                    subTitleFont: nil
                )
                let alert = AlertToast(
                    displayMode: .alert, // .banner(.pop),
                    type: type,
                    title: viewModel.message,
                    subTitle: viewModel.subMessage,
                    style: style
                )
                return alert
            }
    }
}
