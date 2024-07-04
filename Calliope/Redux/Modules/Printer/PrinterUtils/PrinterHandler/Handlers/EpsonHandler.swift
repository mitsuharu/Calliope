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
    
    deinit {
        if let printer {
            finalize(printer: printer)
        }
        printer = nil
    }
    
    func prepare() throws {
        printer = try makePrinter()
    }
    
    func startScan() throws {
        try startScanEpson()
    }
    
    func stopScan() throws {
        try stopScanEpson()
    }
        
    func run(device: PrinterDeviceInfo, jobs: [Print.Job]) async throws {
        guard
            let printer = printer,
            let device = device.epson
        else {
            throw PrinterError.instanceFailed
        }
        
        do {
            try await connectEpson(printer: printer, device: device)
            
            jobs.forEach {
                printer.addPrinterJob(job: $0)
            }
            printer.addFeedLine(4)
            
            try sendData(printer: printer)
        } catch {
            print(error.localizedDescription)
            try await disconnectEpson(printer: printer)
            throw error
        }
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
            print("Epos2Printer.init() failed")
            throw PrinterError.instanceFailed
        }
        
        printer.setReceiveEventDelegate(self)
        
        let result = printer.addTextLang(EPOS2_LANG_JA.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            print("addTextLang failed")
            throw PrinterError.langJaFailed
        }
        
        return printer
    }
        
    private func startScanEpson() throws {
        appStore.dispatch(onMain: PrinterActions.AssignPrinterCandiates(candiates: []))
        
        let filterOption: Epos2FilterOption = Epos2FilterOption()
        
        // プリンターを検索する
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        
        let result = Epos2Discovery.start(filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            print("Epos2Discovery.start() failed")
            throw PrinterError.scanFailed
        }
    }
    
    private func stopScanEpson() throws {
        while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
            // retry stop function
        }
    }
    
    private func connectEpson(printer: Epos2Printer, device: Epos2DeviceInfo) async throws {
        
        // 日本語の設定をする（接続解除でバッファーをクリアするので）
        let resultTextLang = printer.addTextLang(EPOS2_LANG_JA.rawValue)
        if resultTextLang != EPOS2_SUCCESS.rawValue {
            print("addTextLang failed")
            throw PrinterError.langJaFailed
        }
        
        let result = printer.connect(device.target,
                                     timeout:Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            print("connect failed")
            throw PrinterError.connectFailed
        }
                
        isConnected = true
    }
    
    private func sendData (printer: Epos2Printer) throws {
        let result = printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            print("sendData failed")
            throw PrinterError.sendDataFailed
        }
    }
    
    private func disconnectEpson(printer: Epos2Printer) async throws {
        
        let resultClearCommandBuffer = printer.clearCommandBuffer()
        if resultClearCommandBuffer != EPOS2_SUCCESS.rawValue {
            print("clearCommandBuffer failed")
            throw PrinterError.disconnectFailed
        }
        
        let result = printer.disconnect()
        if result != EPOS2_SUCCESS.rawValue {
            print("disconnectEpson failed")
            throw PrinterError.disconnectFailed
        }
        
        isConnected = false
    }
    
    func finalize(printer: Epos2Printer) {
        printer.setReceiveEventDelegate(nil)
    }

}

extension EpsonHandler: Epos2DiscoveryDelegate {
    func onDiscovery(_ deviceInfo: Epos2DeviceInfo) {
        let candiate = PrinterDeviceInfo(epson: deviceInfo)
        appStore.dispatch(onMain: PrinterActions.AppendPrinterCandiate(candiate: candiate))
    }
}

extension EpsonHandler: Epos2PtrReceiveDelegate {
    func onPtrReceive(
        _ printerObj: Epos2Printer,
        code: Int32,
        status: Epos2PrinterStatusInfo,
        printJobId: String)
    {
        if (code == EPOS2_CODE_SUCCESS.rawValue) {
            if let printer {
                Task {
                    try await disconnectEpson(printer: printer)
                }
            }
        } else {
            print("onPtrReceive failed code: \(code)")
        }
    }
}

