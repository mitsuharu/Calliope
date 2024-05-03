//
//  PrinterSelectors.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import AsyncBluetooth

func selectManufacturer(store: AppState) -> PrinterState.Manufacturer {
    store.printer.manufacturer
}

func selectPeripheral(store: AppState) -> Peripheral? {
    store.printer.peripheral
}

func selectPeripherals(store: AppState) -> [Peripheral] {
    store.printer.peripherals
}
