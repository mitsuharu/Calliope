//
//  MainViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import ReSwift

final class MainViewModel: ObservableObject, StoreSubscriber {
    typealias StoreSubscriberStateType = (
        name: String?,
        uuid: String?
    )
    
    @Published var name: String? = nil
    @Published var uuid: String? = nil
    
    init() {
        appStore.subscribe(self) {
            $0.select { (
                selectPrinterName(store: $0),
                selectPrinterUUID(store: $0)
            ) }
        }
    }
    
    deinit {
        appStore.unsubscribe(self)
    }
    
    func newState(state: StoreSubscriberStateType) {
        Task { @MainActor in
            self.name = state.name
            self.uuid = state.uuid
        }
    }
}
