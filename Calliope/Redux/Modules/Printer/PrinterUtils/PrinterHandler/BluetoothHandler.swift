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
    
    func run(device: PrinterDeviceInfo, transaction: [PrinterOrder]) async throws {
        guard let peripheral = device.bluetooth else {
            throw PrinterError.instanceFailed
        }
        
        try await connectBluetooth(peripheral: peripheral)
        
        let uuid = try await peripheral.fetchWritableUUID()
        let value = makeCommandData(transaction: transaction)
        try await peripheral.writeValue(
            value,
            forCharacteristicWithUUID: uuid.characteristic,
            ofServiceWithUUID: uuid.service
        )
        
        try await disconnectBluetooth(peripheral: peripheral)
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
        
        do {
            try await centralManager.waitUntilReady()
            
            let stream = try await centralManager.scanForPeripherals(withServices: nil)
            for await scanData in stream {
                let candiate = PrinterDeviceInfo(bluetooth: scanData.peripheral)
                appStore.dispatch(onMain: AppendPrinterCandiate(candiate: candiate))
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    fileprivate func stopScanBluetooth() async throws {
        await centralManager.stopScan()
    }
    
    fileprivate func connectBluetooth(peripheral: Peripheral) async throws {
        do {
            try await centralManager.connect(peripheral, options: nil)
        } catch {
            print(error)
            throw error
        }
    }
    
    fileprivate func disconnectBluetooth(peripheral: Peripheral) async throws {
        do {
            try await centralManager.cancelPeripheralConnection(peripheral)
        } catch {
            print(error)
            throw error
        }
    }
        
    func makeCommandData(transaction: [PrinterOrder]) -> Data {
        
        // 初期化 ESC @
        var result = Data([0x1b, 0x40]) // Data()
        
        transaction.forEach {
            switch $0 {
            case .text(let text, let size, let style):
                if let d = text.data(using: .shiftJIS) {
                    result.append(d)
                    result.append(0x0a)
                }
            case .feed(let count):
                // https://download4.epson.biz/sec_pubs/pos/reference_ja/escpos/esc_ld.html
                result.append(Data([0x1b, 0x64, UInt8(count)]))
            case .escPosCommond(let data):
                result.append(data)
            }
        }
        
        // 紙送り
        result.append(Data([0x1b, 0x64, UInt8(10)]))
        
        return result
        
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


extension Peripheral {
    
    private typealias UUIDTuple = (service: UUID, characteristics: [UUID])
    typealias PeripheralUUID = (service: UUID, characteristic: UUID)
    
    private func discoverWritableUUIDs() async throws -> [UUIDTuple] {
        
        var results: [UUIDTuple] = []
        
        try await self.discoverServices(nil)
        for service in self.discoveredServices ?? [] {
            try await self.discoverCharacteristics(nil, for: service)
            
            if service.isPrimary == false {
                continue
            }
            
            guard let serviceUUID = UUID(uuidString: service.uuid.uuidString) else {
                continue
            }
            
            let characteristicUUID: [UUID] = service.discoveredCharacteristics?.compactMap{
                // write可能なCharacteristicを対象とする
                if $0.properties.contains(.write) == false
                    && $0.properties.contains(.writeWithoutResponse) == false {
                    return nil
                }
                return UUID(uuidString: $0.uuid.uuidString)
            } ?? []
            
            if characteristicUUID.count == 0 {
                continue
            }
      
            results.append((service: serviceUUID, characteristics: characteristicUUID))
        }
        return results
    }
    
    func fetchWritableUUID() async throws -> PeripheralUUID {
        let uuids = try await self.discoverWritableUUIDs()
 
        guard
            let serviceUUID = uuids.first?.service,
            let characteristicUUID = uuids.first?.characteristics.first
        else {
            throw PrinterError.instanceFailed
        }
        
        let result: PeripheralUUID = (service: serviceUUID,
                                      characteristic: characteristicUUID)
        return result
    }
}
