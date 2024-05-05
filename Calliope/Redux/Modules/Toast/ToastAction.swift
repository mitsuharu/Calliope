//
//  ToastAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

protocol ToastAction: Action {}

struct ShowToast: ToastAction {
    let message: String
}
