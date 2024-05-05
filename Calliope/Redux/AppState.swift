//
//  AppState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

struct AppState {
    let printer: PrinterState

    static func initialState() -> AppState {
        AppState(
            printer: PrinterState.initialState()
        )
    }
}
