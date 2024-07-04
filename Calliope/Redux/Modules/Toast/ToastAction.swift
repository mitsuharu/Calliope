//
//  ToastAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

protocol ToastAction: Action {}

enum ToastActions {
    struct Show: ToastAction {
        let message: String
        let subMessage: String?
        let type: ToastViewModel.ToastType
        
        init(message: String, subMessage: String? = nil, type: ToastViewModel.ToastType = .regular) {
            self.message = message
            self.subMessage = subMessage
            self.type = type
        }
    }
    
    struct Dismiss: ToastAction {
    }
    
}
