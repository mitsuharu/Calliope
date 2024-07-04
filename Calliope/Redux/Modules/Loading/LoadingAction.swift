//
//  LoadingAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

protocol LoadingAction: Action {}

enum LoadingActions {
    struct Show: ToastAction {
        let message: String?
        init(message: String?) {
            self.message = message
        }
    }
    struct Dissmiss: ToastAction {
    }
}
