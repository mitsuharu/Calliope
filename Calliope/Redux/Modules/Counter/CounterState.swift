//
//  CounterState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

struct CounterState {
    let count: Int

    static func initialState() -> CounterState {
        CounterState(count: 0)
    }
}
