//
//  PrinterAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift
import AsyncBluetooth

protocol PrinterAction: Action {}

struct AssignManufacturer: PrinterAction {
    let manufacturer: PrinterState.Manufacturer
}

struct AssignPeripheral: PrinterAction {
    let peripheral: PrinterAction?
}

struct AssignPeripherals: PrinterAction {
    let peripherals: [PrinterAction]
}
