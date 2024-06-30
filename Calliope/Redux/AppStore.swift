//
//  AppStore.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift
import ReSwiftSaga

func makeAppStore() -> Store<AppState> {
    let sagaMiddleware: Middleware<AppState> = createSagaMiddleware()
    
    let persistMiddleware = persistMiddleware()
    
    let store = Store<AppState>(
        reducer: appReducer,
        state: AppState.initialState(),
        middleware: [sagaMiddleware, persistMiddleware]
    )
    
    Task.detached {
        do {
            try await fork(appSage)
        } catch {
            print(error)
        }
    }
    
    return store
}

private func persistMiddleware() -> Middleware<AppState> {
   return { dispatch, getState in
       return { next in
           return { action in
               let nextAction: Void = next(action)
               AppState.persist(action: action, state: getState())
               return nextAction
           }
       }
   }
}

extension Store {
    
    public func dispatch(onMain action: Action) {
        onMainThread { self.dispatch(action) }
    }

    private func onMainThread(_ handler: @escaping () -> Void) {
        if Thread.isMainThread {
            handler()
        } else {
            Task.detached { @MainActor in
                handler()
            }
        }
    }
}
