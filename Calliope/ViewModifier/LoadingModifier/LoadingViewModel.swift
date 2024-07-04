//
//  LoadingViewModel.swift
//  Example
//
//  Created by Mitsuharu Emoto on 2023/09/16.
//

import Foundation

final class LoadingViewModel: ObservableObject {

    static let shared = LoadingViewModel()
    
    private init() { }
    
    @Published var showToast: Bool = false
    private(set) var message: String? = nil
    
    @MainActor
    func show(message: String?) {
        self.showToast = true
        self.message = message
    }
    
    @MainActor
    func dismiss() {
        if self.showToast {
            self.showToast = false
            self.message = nil
        }
    }
}
