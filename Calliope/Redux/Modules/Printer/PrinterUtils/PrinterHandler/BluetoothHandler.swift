//
//  BluetoothHandler.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import Combine
import AsyncBluetooth
import CoreBluetooth

final class BluetoothHandler: PrinterHandlerProtocol {
    
    private let centralManager = CentralManager()    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
    }
    
    deinit {
        cancellables.forEach{ $0.cancel() }
        cancellables.removeAll()
    }
    
    func prepare() throws {
        prepareBluetooth()
    }
        
    func startScan() throws {
        Task {
            try await startScanBluetooth()
        }
    }
    
    func stopScan() throws {
        Task {
            try await stopScanBluetooth()
        }
    }
    
    func run(device: PrinterDeviceInfo, transact: [PrinterOrder]) throws {
    }    
}

extension BluetoothHandler {
    
    fileprivate func prepareBluetooth() {
        AsyncBluetoothLogging.isEnabled = false
        centralManager.eventPublisher
            .sink {
                switch $0 {
                case .didUpdateState(let state):
                    print("update State \(state)")
                case .willRestoreState(let state):
                    print("willRestoreState \(state)")
                case .didConnectPeripheral(let peripheral):
                    print("connected \(peripheral.identifier)")
                case .didDisconnectPeripheral(let peripheral, let isReconnecting, let error):
                    print("disconnected \(peripheral.identifier), isReconnecting: \(isReconnecting), error: \(error?.localizedDescription ?? "none")")
                }
            }
            .store(in: &cancellables)
    }
    
    fileprivate func startScanBluetooth() async throws {
        appStore.dispatch(onMain: AssignPrinterCandiates(candiates: []))
        
        // peripheral: Optional("CloudPrint_0449"), B1F5385B-AB54-B398-F8F2-46391AB93EEA
        
        do {
            try await centralManager.waitUntilReady()
            
            let stream = try await centralManager.scanForPeripherals(withServices: nil)
            for await scanData in stream {
                
                let peripheral = scanData.peripheral
                let candiate = PrinterDeviceInfo(bluetooth: peripheral)
                appStore.dispatch(onMain: AppendPrinterCandiate(candiate: candiate))
                
                
//                // sunmi 58 kitchen cloud printer
//                if peripheral.identifier.uuidString == "B1F5385B-AB54-B398-F8F2-46391AB93EEA" {
//                    self.peripheral = peripheral
//                    await centralManager.stopScan()
//                    await connect(peripheral: peripheral)
//                }
            }
            
        } catch {
            print(error)
            throw error
        }
    }
    
    fileprivate func stopScanBluetooth() async throws {
        await centralManager.stopScan()
    }
    
    
    fileprivate func connect(peripheral: Peripheral) async {
        
        let characteristicUUID = CBUUID()
        print("characteristicUUID: \(characteristicUUID)")
        
        peripheral.characteristicValueUpdatedPublisher
            .filter {
                print("$0.uuid: \($0.uuid)")
                return $0.uuid == characteristicUUID }
            .map { try? $0.parsedValue() as String? } // replace `String?` with your type
            .sink { value in
                print("Value updated to '\(String(describing: value))'")
            }
            .store(in: &cancellables)
        
        do {
            try await centralManager.connect(peripheral, options: nil)
            
            try await peripheral.discoverServices(nil)
            
            for service in peripheral.discoveredServices ?? [] {
                print("service: \(service)")
                try await peripheral.discoverCharacteristics(nil, for: service)
                
                if let serviceUUID = UUID(uuidString: service.uuid.uuidString) {
                    let characteristics = service.discoveredCharacteristics?.map {
                                   "\($0.uuid)"
                               }.joined(separator: ", ") ?? "-"
                    print("service serviceUUID: \(service.uuid), characteristics: \(characteristics)")
                }
            }
            
            // sunmi 58 kitchen cloud printer
            let sUUID = "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"
            let cUUID = "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"
            
            let value = makeData()
            
            
            try await peripheral.writeValue(
                value,
                forCharacteristicWithUUID: UUID(uuidString: cUUID)!,
                ofServiceWithUUID: UUID(uuidString: sUUID)!
            )
            
        } catch {
            
        }

    }
    
    func makeData() -> Data {
        
        // 初期化 ESC @
        var data = Data([0x1b, 0x40])
        
        // 日本語設定
        
        // 文字コードテーブルの選択
        // https://download4.epson.biz/sec_pubs/pos/reference_ja/escpos/esc_lt.html
        data.append(Data([0x1b, 0x74, 1]))
        
        // 文字コードを Shift-JIS に設定
        // https://download4.epson.biz/sec_pubs/pos/reference_ja/escpos/fs_cc.html
        data.append(Data([0x1c, 0x43, 0x01]))
//
//        // 国際文字セットを日本語に設定
//        // https://download4.epson.biz/sec_pubs/pos/reference_ja/escpos/esc_cr.html
//        data.append(Data([0x1b, 0x52, 0x08]))

//        // 漢字モードを有効化
//        // https://download4.epson.biz/sec_pubs/pos/reference_ja/escpos/fs_ampersand.html
//        data.append(Data([0x1c, 0x26]))
        
//        // 内蔵フォントを選択
//        data.append(Data([0x1b, 0x4d, 0x00]))
        
        // 日本語設定こkまで
        
        data.append(Data([0x1b, 0x45, 0x00]))
        if let d = "Hello, world!\n".data(using: .ascii) {
            data.append(d)
        }
        data.append(Data([0x1b, 0x45, 0x00]))
        
        if let d = "1.コンニチハ".data(using: .shiftJIS) {
            print(d)
            data.append(d)
            data.append(0x0a)
        }
        
        if let d = "2.ｺﾝﾆﾁﾊ".data(using: .shiftJIS) {
            print(d)
            data.append(d)
            data.append(0x0a)
        }
        
        if let d = "3.こんにちは".data(using: .shiftJIS) {
            print(d)
            data.append(d)
            data.append(0x0a)
        }
        
        if let d = "4.漢字漢字".data(using: .shiftJIS) {
            print(d)
            data.append(d)
            data.append(0x0a)
        }
        
        for _ in 0...4 {
            data.append(0x0a)  // 改行
        }
//            if let d = "\n\n\n\n".data(using: .ascii) {
//            data.append(d)
//        }
        return data
//        // 太字の有効化
//        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=25
//        let boldOnCommand = Data([0x1b, 0x45, 0x01]) // ESC E 1
//        printer.addCommand(boldOnCommand)
//
//        // テキストデータの追加
//        let textData = "Hello, world!\n".data(using: .ascii)
//        printer.addCommand(textData)
//        printer.addFeedLine(1)
//
//        // 太字の無効化
//        let boldOffCommand = Data([0x1b, 0x45, 0x00]) // ESC E 0
//        printer.addCommand(boldOffCommand)
    }
    
}
