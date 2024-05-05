//
//  EpsonHandler.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

final class EpsonHandler: NSObject, PrinterHandlerProtocol {
    
    var printer: Epos2Printer? = nil
    var isConnected: Bool = false
    
    func prepare() throws {
        printer = try makePrinter()
    }
    
    func startScan() throws {
        try startScanEpson()
    }
    
    func stopScan() throws {
        try stopScanEpson()
    }
        
    func run(device: PrinterDeviceInfo, transaction: [PrinterOrder]) async throws {
        guard
            let printer = printer,
            let device = device.epson
        else {
            throw PrinterError.instanceFailed
        }
        try await connectEpson(printer: printer, device: device)
        
        // transact 内の SDK のコマンドを使った例、一旦コメントアウト
        transaction.forEach {
            printer.addPrinterOrder(order: $0)
        }
        printer.addFeedLine(4)
        
        do {
            try sendData(printer: printer)
        } catch {
            try await disconnectEpson(printer: printer)
        }
    }
}

extension EpsonHandler {
    
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

extension EpsonHandler {
    
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
    
    private func startScanEpson() throws {
        appStore.dispatch(onMain: AssignPrinterCandiates(candiates: []))
        
        let filterOption: Epos2FilterOption = Epos2FilterOption()
        
        // プリンターを検索する
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        
        let result = Epos2Discovery.start(filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            throw PrinterError.scanFailed
        }
    }
    
    private func stopScanEpson() throws {
        while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
            // retry stop function
        }
    }
    
    private func connectEpson(printer: Epos2Printer, device: Epos2DeviceInfo) async throws {
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
    
    private func disconnectEpson(printer: Epos2Printer) async throws {
        let result = printer.disconnect()
        if result != EPOS2_SUCCESS.rawValue {
            throw PrinterError.disconnectFailed
        }
    }
}

extension EpsonHandler: Epos2DiscoveryDelegate {
    
    func onDiscovery(_ deviceInfo: Epos2DeviceInfo) {
        let candiate = PrinterDeviceInfo(epson: deviceInfo)
        appStore.dispatch(onMain: AppendPrinterCandiate(candiate: candiate))
    }
}
