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
        
        // transact 内の SDK のコマンドを使った例、一旦コメントアウト
//        transact(printer)
        
        // ESC/POSコマンドを実行した場合の例
        addPOSCommand(printer: printer)

        printer.addFeedLine(5)
        do {
            try sendData(printer: printer)
        } catch {
            try disconnect(printer: printer)
        }
    }
}

extension EpsonPrinterRepository {
    
    /**
     @see: https://www.epson-biz.com/pos/reference_ja/
     */
    func addPOSCommand(printer: Epos2Printer) {
        // 太字の有効化
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=25
        let boldOnCommand = Data([0x1b, 0x45, 0x01]) // ESC E 1
        printer.addCommand(boldOnCommand)
        
        // テキストデータの追加
        let textData = "Hello, world!\n".data(using: .ascii)
        printer.addCommand(textData)
        printer.addFeedLine(1)
        
        // 太字の無効化
        let boldOffCommand = Data([0x1b, 0x45, 0x00]) // ESC E 0
        printer.addCommand(boldOffCommand)
                
        // 二重印字
        printer.addCommand(Data([0x1b, 0x47, 0x01]))
        printer.addCommand("nijuinji\n".data(using: .ascii))
        printer.addCommand("二重印字\n".data(using: .ascii))
        printer.addText("二重印字\n")
        printer.addFeedLine(1)
        printer.addCommand(Data([0x1b, 0x47, 0x00]))
        
        if let text = "こんにちは".data(using: .shiftJIS) {
            printer.addCommand(text)
        }

//        // QRコードのモデル設定
//        let modelCommand = Data([0x1d, 0x28, 0x6b, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00])
//        printer.addCommand(modelCommand)
//
//        // QRコードのサイズ設定
//        let sizeCommand = Data([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x43, 0x08])
//        printer.addCommand(sizeCommand)
//
//        // QRコードのエラー訂正レベル設定
//        let errorCorrectionCommand = Data([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x45, 0x33])
//        printer.addCommand(errorCorrectionCommand)
//
//        // QRコードデータの追加
//        let qrData = "http://www.example.com"
//        let pL = UInt8((qrData.count + 3) % 256)
//        let pH = UInt8((qrData.count + 3) / 256)
//        var storeCommand = Data([0x1d, 0x28, 0x6b, pL, pH, 0x31, 0x50, 0x30])
//        storeCommand.append(qrData.data(using: .ascii)!)
//        printer.addCommand(storeCommand)
//
//        // QRコードの印刷命令
//        let printCommand = Data([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x51, 0x30])
//        printer.addCommand(printCommand)
        
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
        let result = printer.addTextLang(EPOS2_LANG_JA.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            throw PrinterError.langJaFailed
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
