//
//  AppReducer.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {

    let state = state ?? AppState.initialState()

    var nextCounter = state.counter

    switch action {
    case let action as CounterAction:
        nextCounter = counterReducer(action: action, state: state.counter)
    
    default:
        break
    }
    
    return AppState(
        counter: nextCounter
    )
}
