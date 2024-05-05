//
//  PrinterSelectors.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

func selectPrinterDeviceInfo(stare: AppState) -> PrinterDeviceInfo? {
    stare.printer.deviceInfo
}

func selectPrinterCandiates(stare: AppState) -> [PrinterDeviceInfo] {
    let candiates = (stare.printer.candiates ?? []).sorted { lhs, rhs in
        let keyword = "CloudPrint" // TM-P20II
        switch (lhs.name, rhs.name) {
        case (let leftName?, let rightName?):
            let left = leftName.contains(keyword)
            let right = rightName.contains(keyword)
            if left && !right {
                return true
            } else if !right {
                return false
            }
            return leftName.lowercased() < rightName.lowercased()
        case (nil, nil):
            return false
        case (nil, _):
            return false
        case (_, nil):
            return true
        }
    }
    return candiates
}

func selectPrinterName(stare: AppState) -> String? {
    guard let deviceInfo = selectPrinterDeviceInfo(stare: stare) else {
        return nil
    }
    return deviceInfo.name
}

func selectPrinterUUID(stare: AppState) -> String? {
    guard let deviceInfo = selectPrinterDeviceInfo(stare: stare) else {
        return nil
    }
    return deviceInfo.uuid
}
