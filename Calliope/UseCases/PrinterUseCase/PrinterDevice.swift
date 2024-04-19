//
//  PrinterDevice.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import Foundation

struct PrinterDevice {
    let name: String
    let target: String
    let ipAddress: String
    let macAddress: String
    let bdAddress: String
    let leBdAddress: String
}

extension PrinterDevice {
    static func convert(from epos2DeviceInfo: Epos2DeviceInfo) -> PrinterDevice {
        PrinterDevice(name: epos2DeviceInfo.deviceName as String,
                      target: epos2DeviceInfo.target as String,
                      ipAddress: epos2DeviceInfo.ipAddress as String,
                      macAddress: epos2DeviceInfo.macAddress as String,
                      bdAddress: epos2DeviceInfo.bdAddress as String,
                      leBdAddress: epos2DeviceInfo.leBdAddress as String)
    }
}
