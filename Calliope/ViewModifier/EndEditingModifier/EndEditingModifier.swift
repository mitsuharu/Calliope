//
//  EndEditingModifier.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/07/05.
//

import Foundation
import SwiftUI

struct EndEditingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
