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

    var nextPrinter = state.printer
    
    switch action {
    case let action as PrinterAction:
        nextPrinter = printerReducer(action: action, state: state.printer)
    
    default:
        break
    }
    
    return AppState(
        printer: nextPrinter
    )
}
