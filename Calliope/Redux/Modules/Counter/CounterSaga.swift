//
//  CounterSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let counterSaga: Saga = { _ in
    await takeEvery(Increase.self, saga: increaseSaga)
    await takeLatest(Decrease.self, saga: decreaseSaga)
    await takeLeading(Assign.self, saga: assignSaga)
}

private let increaseSaga: Saga = { action async in
    guard let action = action as? Increase else {
        return
    }
    print("increaseSaga#start", action )
}

private let decreaseSaga: Saga = { action async in
    guard let action = action as? Decrease else {
        return
    }
    print("decreaseSaga#start", action )

    try? await Task.sleep(nanoseconds: 1_000_000_000)
    print("decreaseSaga#end", action )
}

private let assignSaga: Saga = { action async in
    guard let move = action as? Assign else {
        return
    }

    print("moveSaga#start move", move, move.count)
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    print("moveSaga#end move", move, move.count)
}

