//
//  PrinterDeviceInfo.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import AsyncBluetooth

struct PrinterDeviceInfo {    
    enum Manufacturer {
        case epson
        case bluetooth
        
        var name: String {
            get {
                switch self {
                case .epson:
                    return "EPSON"
                case .bluetooth:
                    return "Bluetooth汎用機器"
                }
            }
        }
    }
    
    let manufacturer: PrinterDeviceInfo.Manufacturer
    let epson: Epos2DeviceInfo?
    let bluetooth: Peripheral?
    
    init(epson: Epos2DeviceInfo) {
        self.manufacturer = .epson
        self.epson = epson
        self.bluetooth = nil
    }
    
    init(bluetooth: Peripheral) {
        self.manufacturer = .bluetooth
        self.epson = nil
        self.bluetooth = bluetooth
    }
}

extension PrinterDeviceInfo: Hashable {
    
    static func == (lhs: PrinterDeviceInfo, rhs: PrinterDeviceInfo) -> Bool {
        let isEqualToManufacturer = lhs.manufacturer == rhs.manufacturer
        let isEqualToEpson = lhs.epson?.target == rhs.epson?.target
        let isEqualToBluetooth = lhs.bluetooth?.identifier.uuidString == rhs.bluetooth?.identifier.uuidString
        let isEqual = isEqualToManufacturer && isEqualToEpson && isEqualToBluetooth
        
        return isEqual
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(manufacturer)
            hasher.combine(epson?.target)
            hasher.combine(bluetooth?.identifier.uuidString)
    }
}

extension PrinterDeviceInfo {
    
    var name: String? {
        get {
            switch manufacturer {
            case .epson:
                return epson?.deviceName
            case .bluetooth:
                return bluetooth?.name
            }
        }
    }
    
    var uuid: String {
        get {
            switch manufacturer {
            case .epson:
                return epson?.target ?? "none"
            case .bluetooth:
                return bluetooth?.identifier.uuidString ?? "none"
            }
        }
    }
    
}
