//
//  SunmiBluetoothHandler.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import Combine
import AsyncBluetooth
import CoreBluetooth

final class SunmiBluetoothHandler: PrinterHandlerProtocol {
    
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
    
    func run(device: PrinterDeviceInfo, transaction: [Print.Instruction]) async throws {
        guard let peripheral = device.bluetooth else {
            throw PrinterError.instanceFailed
        }
        
        try await connectBluetooth(peripheral: peripheral)
        
        let value = makeCommandData(transaction: transaction)
        try await send(peripheral: peripheral, data: value)
        
        try await disconnectBluetooth(peripheral: peripheral)
    }
    
}

extension SunmiBluetoothHandler {
    
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
        
    fileprivate func makeCommandData(transaction: [Print.Instruction]) -> Data {
        
        // 初期化 ESC @
        var result = EpsonEscPosCommond.initialize()
        
        transaction.forEach {
            print("makeCommandData \($0)")
            result.append($0.sunmiBluetoothCommand)
        }
        
        // 紙送り
        result.append(EpsonEscPosCommond.feed())
        
        return result
    }
    
    fileprivate func send(peripheral: Peripheral, data: Data) async throws{
        
        // サービスとキャラクタリスティックのUUIDを取得する
        let uuid = try await peripheral.fetchWritableUUID()
        
        // MTUサイズの取得
        let mtuSize = peripheral.maximumWriteValueLength(for: .withoutResponse)

        var offset = 0
        while offset < data.count {
            let chunkSize = min(mtuSize, data.count - offset)
            let chunk = data.subdata(in: offset..<(offset + chunkSize))
            try await peripheral.writeValue(
                chunk,
                forCharacteristicWithUUID: uuid.characteristic,
                ofServiceWithUUID: uuid.service
            )
            offset += chunkSize
        }
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