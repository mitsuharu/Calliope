//
//  AppState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

struct AppState {
    let counter: CounterState

    static func initialState() -> AppState {
        AppState(
            counter: CounterState.initialState()
        )
    }
}
