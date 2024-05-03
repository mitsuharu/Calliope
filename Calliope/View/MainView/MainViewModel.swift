//
//  MainViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import ReSwift
import AsyncBluetooth

@Observable
final class MainViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = (
        manufacturer: PrinterState.Manufacturer,
        peripheral: Peripheral?
    )
    
    private(set) var manufacturer: PrinterState.Manufacturer = .notSelected
    private(set) var peripheral: Peripheral? = nil
    
    init() {
        appStore.subscribe(self) {
            $0.select { (
                selectManufacturer(store: $0),
                selectPeripheral(store: $0)
            ) }
        }
    }
    
    deinit {
        appStore.unsubscribe(self)
    }
    
    func newState(state: StoreSubscriberStateType) {
        self.manufacturer = state.manufacturer
        self.peripheral = state.peripheral
    }
}
