//
//  ToastViewModel.swift
//  Example
//
//  Created by Mitsuharu Emoto on 2023/09/16.
//

import Foundation

final class ToastViewModel: ObservableObject {

    static let shared = ToastViewModel()
    
    private init() { }
    
    @Published var showToast: Bool = false
    private(set) var message: String = ""

    @MainActor
    func showToast(message: String) {
        self.showToast = true
        self.message = message
    }
}
