//
//  PrinterSelectors.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

func selectPrinterDeviceInfo(store: AppState) -> PrinterDeviceInfo? {
    store.printer.deviceInfo
}

func selectPrinterCandiates(store: AppState) -> [PrinterDeviceInfo] {
    Array(store.printer.candiates ?? [])
}

func selectPrinterName(store: AppState) -> String? {
    guard let deviceInfo = selectPrinterDeviceInfo(store: store) else {
        return nil
    }
    return deviceInfo.name
}

func selectPrinterUUID(store: AppState) -> String? {
    guard let deviceInfo = selectPrinterDeviceInfo(store: store) else {
        return nil
    }
    return deviceInfo.uuid
}
