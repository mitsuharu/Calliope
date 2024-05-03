//
//  PrinterState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import AsyncBluetooth

struct PrinterState {
    
    let manufacturer: Manufacturer
    
    /**
     選択されたBluetooth機器
     */
    let peripheral: Peripheral?
    
    /**
     スキャンで検出されたBluetooth機器
     */
    let peripherals: [Peripheral]

    static func initialState() -> PrinterState {
        PrinterState(
            manufacturer: .notSelected,
            peripheral: nil,
            peripherals: []
        )
    }
}

extension PrinterState {
    
    /**
     機種の製造メーカー
     */
    enum Manufacturer {
        
        /**
         EPSON
         */
        case epson
        
        /**
         特定メーカーなし（専用SDKなしでBluetoothで接続する）
         */
        case notSpecified
        
        /**
         選択なし（初期値）
         */
        case notSelected
    }
}
