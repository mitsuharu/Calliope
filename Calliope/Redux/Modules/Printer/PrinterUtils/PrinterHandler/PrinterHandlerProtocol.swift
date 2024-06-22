//
//  PrinterHandleProtocol.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

protocol PrinterHandlerProtocol {
    
    func prepare() throws -> Void
    
    func startScan() throws -> Void
    
    func stopScan() throws -> Void
        
    func run(device: PrinterDeviceInfo, transaction: [Print.Job]) async throws -> Void
}
