//
//  PrinterReducer.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

func printerReducer(action: PrinterAction, state: PrinterState) -> PrinterState {
    
    switch action {
    case let action as AssignPrinterDeviceInfo:
        return PrinterState(deviceInfo: action.deviceInfo, candiates: nil)
        
    case let action as AssignPrinterCandiates:
        return PrinterState(deviceInfo: state.deviceInfo, candiates: action.candiates)
        
    case let action as AppendPrinterCandiate:
        
        var nextCandiates : Set<PrinterDeviceInfo> = (state.candiates ?? [])
        nextCandiates.insert(action.candiate)
        
        return PrinterState(
            deviceInfo: state.deviceInfo,
            candiates: nextCandiates
        )
        
    default:
        return state
    }
}
