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
    
    enum ToastType {
        case regular
        case error
    }
    
    @Published var showToast: Bool = false
    private(set) var type: ToastType = .regular
    private(set) var message: String = ""
    private(set) var subMessage: String? = nil

    @MainActor
    func showToast(message: String, subMessage: String?, type: ToastType) {
        self.showToast = true
        self.message = message
        self.subMessage = subMessage
        self.type = type
    }
}
