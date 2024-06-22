//
//  PrinterHandler.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

final class PrinterHandler: PrinterHandlerProtocol {

    let epson = EpsonHandler()
    let bluetooth = SunmiBluetoothHandler()

    static let shared = PrinterHandler()
    private init() {}
    
    func prepare() throws {
        try epson.prepare()
        try bluetooth.prepare()
    }
    
    func startScan() throws {
        try epson.startScan()
        try bluetooth.startScan()
    }
    
    func stopScan() throws {
        try epson.stopScan()
        try bluetooth.stopScan()
    }
    
    func run(device: PrinterDeviceInfo, transaction: [Print.Job]) async throws {
        switch device.manufacturer {
        case .epson:
            try await epson.run(device: device, transaction: transaction)
        case .bluetooth:
            try await bluetooth.run(device: device, transaction: transaction)
        }
    }
    
}
