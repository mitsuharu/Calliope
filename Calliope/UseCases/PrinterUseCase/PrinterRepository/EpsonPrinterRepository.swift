//
//  EpsonPrinterRepository.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import Foundation

final class EpsonPrinterRepository: NSObject, PrinterRepositoryProtocol {
    typealias PrinterType = Epos2Printer
    
    fileprivate var devices: [PrinterDevice] = []
    
    func scan() throws {
        devices.removeAll()
        
        let filterOption: Epos2FilterOption = Epos2FilterOption()
        
        // プリンターを検索する
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        
        let result = Epos2Discovery.start(filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            throw PrinterError.scanFailed
        }
    }
    
    func stopScan() {
        while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
            // retry stop function
        }
    }
    
    func run(device: PrinterDevice, transact: Transact) throws {
        let printer = try makePrinter()
        try connect(printer: printer, device: device)
        
        transact(printer)

        do {
            try sendData(printer: printer)
        } catch {
            try disconnect(printer: printer)
        }
    }
}

extension EpsonPrinterRepository {
    
    private func makePrinter(
        series: Epos2PrinterSeries = EPOS2_TM_P20,
        languge: Epos2ModelLang = EPOS2_MODEL_JAPANESE
    ) throws -> Epos2Printer {
        let printer = Epos2Printer(printerSeries: series.rawValue,
                                   lang: languge.rawValue)
        guard let printer = printer else {
            throw PrinterError.instanceFailed
        }
        return printer
    }
    
    private func connect(printer: Epos2Printer, device: PrinterDevice) throws {
        let result = printer.connect(device.target,
                                     timeout:Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            throw PrinterError.connectFailed
        }
    }
    
    private func sendData (printer: Epos2Printer) throws {
        let result = printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            printer.clearCommandBuffer()
            throw PrinterError.sendDataFailed
        }
    }
    
    private func disconnect(printer: Epos2Printer) throws {
        let result = printer.disconnect()
        if result != EPOS2_SUCCESS.rawValue {
            throw PrinterError.disconnectFailed
        }
    }
}


extension EpsonPrinterRepository: Epos2DiscoveryDelegate {
    func onDiscovery(_ deviceInfo: Epos2DeviceInfo) {
        let device = PrinterDevice.convert(from: deviceInfo)
        devices.append(device)
        
        stopScan()
        try? run(device: device, transact: { printer in
            printer.addText("test")
            printer.addFeedLine(5)
        })
        
    }
}
