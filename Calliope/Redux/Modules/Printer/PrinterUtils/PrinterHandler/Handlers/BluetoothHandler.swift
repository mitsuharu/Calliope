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

final class BluetoothHandler: PrinterHandlerProtocol {
    
    private let centralManager = CentralManager()    
    private var cancellables: Set<AnyCancellable> = []
    
    // スキャンする際に候補対象にする機器を名前で絞る
    private let containedDeviceName = "CloudPrint"
    
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
    
    func run(device: PrinterDeviceInfo, jobs: [Print.Job]) async throws {
        guard let peripheral = device.bluetooth else {
            throw PrinterError.instanceFailed
        }
        
        try await connectBluetooth(peripheral: peripheral)
        
        let value = makeCommandData(jobs: jobs)
        try await send(peripheral: peripheral, data: value)
        
        try await disconnectBluetooth(peripheral: peripheral)
    }
    
}

extension BluetoothHandler {
    
    fileprivate func showToastForCentralManagerEvent(state: CentralManagerEvent) {
        switch state {
        case .didUpdateState(let state):
            self.showToastForCBManagerState(state: state)
        case .willRestoreState(let state):
            let message = "状態を復元しています"
            let subMessage = state.map({ (key: String, value: Any) in
                "\(key):\(value)"
            }).joined(separator: ", ")
            showToast(message: message, subMessage: subMessage, type: .error)
        case .didConnectPeripheral(_):
            break
//            let message = "\(peripheral.name ?? peripheral.identifier.uuidString)と接続しました"
//            showToast(message: message, subMessage: nil, type: .regular)
        case .didDisconnectPeripheral(let peripheral, _, let error):
            if let error {
                let message = "\(peripheral.name ?? "Bluetooth機器")と接続が切れました。"
                let subMessage = "エラー：\(error.localizedDescription)"
                showToast(message: message, subMessage: subMessage.isEmpty ? nil : subMessage, type: .error)
            }
        }
    }
    
    fileprivate func showToastForCBManagerState(state: CBManagerState) {
        let message: String? = switch state {
        case .unknown: "Bluetoothの状態が不明です"
        case .resetting: "Bluetoothがリセットされています"
        case .unsupported: "Bluetoothをサポートしていません"
        case .unauthorized: "このアプリはBluetoothの使用を許可されていません。設定から許可してください。"
        case .poweredOff: "Bluetoothがオフになっています。設定でBluetoothを有効にしてください。"
//        case .poweredOn: "Bluetoothは電源オンで準備完了です"
        default: nil
        }
        let type: ToastViewModel.ToastType = switch state {
        case .unknown, .unsupported, .resetting, .unauthorized, .poweredOff: .error
        default: .regular
        }
        showToast(message: message, subMessage: nil, type: type)
    }
    
    fileprivate func showToast(message: String?, subMessage: String?, type: ToastViewModel.ToastType) {
        if let message {
            appStore.dispatch(onMain: ToastActions.Show(
                message: message,
                subMessage: subMessage,
                type: type
            ))
        }
    }
    
    fileprivate func prepareBluetooth() {
        AsyncBluetoothLogging.isEnabled = false
        
        centralManager.eventPublisher
            .sink { [weak self] in
                self?.showToastForCentralManagerEvent(state: $0)
            }
            .store(in: &cancellables)
        
    }
    
    fileprivate func startScanBluetooth() async throws {
        appStore.dispatch(onMain: PrinterActions.AssignPrinterCandiates(candiates: []))
                
        do {
            try await centralManager.waitUntilReady()
            
            let stream = try await centralManager.scanForPeripherals(withServices: nil)
            for await scanData in stream {
                if let name = scanData.peripheral.name, name.contains(containedDeviceName){
                    let candiate = PrinterDeviceInfo(bluetooth: scanData.peripheral)
                    appStore.dispatch(onMain: PrinterActions.AppendPrinterCandiate(candiate: candiate))
                }
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
        
    fileprivate func makeCommandData(jobs: [Print.Job]) -> Data {
        
        // 初期化 ESC @
        var result = SunmiEscPosCommond.initialize()
        
        jobs.forEach {
            result.append($0.sunmiEscPosCommand)
        }
        
        // 紙送り
        result.append(SunmiEscPosCommond.feed(count: 4))
        
        return result
    }
    
    fileprivate func send(peripheral: Peripheral, data: Data) async throws{
        
        // サービスとキャラクタリスティックのUUIDを取得する
        let uuid = try await peripheral.fetchWritableUUID()
        
        // FIXME: MTUサイズの取得で、関数で取得すると値が大きく、印刷で失敗する
//        let mtuSize = peripheral.maximumWriteValueLength(for: .withResponse)
//        print("mtuSize: \(mtuSize)")

        // MTUサイズの取得
        // 値はヒューリスティックに決めた。180ぐらいまでOK、200はNGだったので、安全牌
        let mtuSize = 180
        
        // MTUサイズ単位で分割して、送信する
        for chunk in data.chunk(size: mtuSize) {
            try await peripheral.writeValue(
                chunk,
                forCharacteristicWithUUID: uuid.characteristic,
                ofServiceWithUUID: uuid.service,
                type: .withResponse
            )
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


extension Data {
    
    /**
     Data を size ごとに分割する
     */
    fileprivate func chunk(size: Int) -> [Data] {
        let count = self.count
        var chunks: [Data] = []
        var offset = 0
        while offset < count {
            let chunkLength = Swift.min(size, count - offset)
            let chunk = self.subdata(in: offset..<(offset + chunkLength))
            chunks.append(chunk)
            offset += chunkLength
        }
        return chunks
    }
}
