//
//  PrinterRepositoryProtocol.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import Foundation

protocol PrinterRepositoryProtocol {
    associatedtype PrinterType
    
    typealias Transact = (PrinterType) -> Void
    
    /**
     端末に接続している対応POSプリンターをスキャンする
     
     @note
     PrinterDevice を出力する処理が必要
     */
    func scan() throws -> Void
    
    func stopScan() throws -> Void
    
    func run(device: PrinterDevice, transact: Transact) throws
}

