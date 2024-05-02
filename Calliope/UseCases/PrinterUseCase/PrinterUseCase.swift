//
//  PrinterUseCase.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import Foundation

final class PrinterUseCase {
    
    private let repository: any PrinterRepositoryProtocol

    init(repository: any PrinterRepositoryProtocol = BluetoothPrinterRepository()){ //} EpsonPrinterRepository()) {
        self.repository = repository
    }
        
    func scan() throws {
        try repository.scan()
    }
        
}

extension PrinterUseCase {
    
    func run() {
        print("run is 今停止中")
        try? scan()
    }
}
