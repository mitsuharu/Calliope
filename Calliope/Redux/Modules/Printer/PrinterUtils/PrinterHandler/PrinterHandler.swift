//
//  PrinterHandler.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

final class PrinterHandler: PrinterHandlerProtocol {

    let epson = EpsonHandler()
    let bluetooth = BluetoothHandler()

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
    
    func run(device: PrinterDeviceInfo, transact: [PrinterOrder]) throws {
        switch device.manufacturer {
        case .epson:
            try epson.run(device: device, transact: transact)
        case .bluetooth:
            try bluetooth.run(device: device, transact: transact)
        }
    }
    
}
