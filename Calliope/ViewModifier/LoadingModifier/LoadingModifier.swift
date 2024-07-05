//
//  LoadingModifier.swift
//  Example
//
//  Created by Mitsuharu Emoto on 2023/09/16.
//

import SwiftUI
import AlertToast

struct LoadingModifier: ViewModifier {
    
    @ObservedObject private var viewModel = LoadingViewModel.shared
 
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $viewModel.showToast, duration: 0, tapToDismiss: false) {
                let style = AlertToast.AlertStyle.style(
                    backgroundColor: .gray,
                    titleColor: .white,
                    subTitleColor: nil,
                    titleFont: nil,
                    subTitleFont: nil
                )
                let alert = AlertToast(
                    displayMode: .alert, // .banner(.pop),
                    type: .loading,
                    title: viewModel.message,
                    subTitle: nil,
                    style: style
                )
                return alert
            }
    }
}
