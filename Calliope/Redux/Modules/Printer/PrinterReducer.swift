//
//  PrinterReducer.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import AsyncBluetooth

func printerReducer(action: PrinterAction, state: PrinterState) -> PrinterState {
    
    switch action {
    case let action as AssignManufacturer:
        return PrinterState(
            manufacturer: action.manufacturer,
            peripheral: state.peripheral,
            peripherals: state.peripherals
        )
        
    case let action as AssignPeripheral:
        return PrinterState(
            manufacturer: state.manufacturer,
            peripheral: action.peripheral as? Peripheral,
            peripherals: state.peripherals
        )
    
    case let action as AssignPeripherals:
        return PrinterState(
            manufacturer: state.manufacturer,
            peripheral: state.peripheral,
            peripherals: action.peripherals as? [Peripheral] ?? []
        )
        
    default:
        return state
    }
}
