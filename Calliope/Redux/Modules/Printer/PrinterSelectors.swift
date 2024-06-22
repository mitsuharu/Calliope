//
//  PrinterSelectors.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

enum PrinterSelectors {
    
    static func selectPrinterDeviceInfo(stare: AppState) -> PrinterDeviceInfo? {
        stare.printer.deviceInfo
    }
    
    static func selectPrinterCandiatesExist(stare: AppState) -> Bool {
        guard let candiates = stare.printer.candiates else {
            return false
        }
        return !candiates.isEmpty
    }

    static func selectPrinterCandiates(stare: AppState) -> [PrinterDeviceInfo] {
        guard let candiates = stare.printer.candiates else {
            return []
        }
        return Array(candiates)
    }
    
    static func selectPrinterManufacturerCandiates(stare: AppState) -> [PrinterDeviceInfo.Manufacturer: [PrinterDeviceInfo]] {
        guard let candiates = stare.printer.candiates else {
            return [:]
        }
        return fetchManufacturerCandiates(candiates: candiates)
    }

    static func selectPrinterName(stare: AppState) -> String? {
        guard let deviceInfo = selectPrinterDeviceInfo(stare: stare) else {
            return nil
        }
        return deviceInfo.name
    }

    static func selectPrinterUUID(stare: AppState) -> String? {
        guard let deviceInfo = selectPrinterDeviceInfo(stare: stare) else {
            return nil
        }
        return deviceInfo.uuid
    }

}

fileprivate extension PrinterSelectors {
        
    static func fetchManufacturerCandiates(candiates: Set<PrinterDeviceInfo>) -> [PrinterDeviceInfo.Manufacturer: [PrinterDeviceInfo]] {
        var result: [PrinterDeviceInfo.Manufacturer: [PrinterDeviceInfo]] = [
            .epson: [],
            .bluetooth: []
        ]
        for candiate in candiates {
            switch candiate.manufacturer {
            case .epson:
                result[.epson]?.append(candiate)
            case .bluetooth:
                result[.bluetooth]?.append(candiate)
            }
        }
        return result
    }
}
