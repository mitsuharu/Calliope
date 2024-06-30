//
//  AppState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

struct AppState {
    let printer: PrinterState

    static func initialState() -> AppState {
        AppState(
            printer: PrinterState.initialState()
        )
    }
    
    static func persist(action: Action, state: AppState?) {
        if (action is PrinterActions.AppendBuildJobs || action is PrinterActions.DeleteBuildJobs), let state {
            PrinterState.save(state.printer)
        }
    }
}
