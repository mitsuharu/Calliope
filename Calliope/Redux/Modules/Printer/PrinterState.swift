//
//  PrinterState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

struct PrinterState {
    
    let deviceInfo: PrinterDeviceInfo?
    let candiates: Set<PrinterDeviceInfo>?
    
    static func initialState() -> PrinterState {
        PrinterState(
            deviceInfo: nil,
            candiates: nil
        )
    }
}
