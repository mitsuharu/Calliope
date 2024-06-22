//
//  PrinterSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let printerSaga: Saga = { _ in
    
    try? await fork(preparePrinterHandlerSaga)
    
    await takeEvery(StartScanDevices.self, saga: startScanSaga)
    await takeEvery(StopScanDevices.self, saga: stopScanSaga)
    await takeEvery(RunPrintJobs.self, saga: runPrintJobsSaga)
}

private let preparePrinterHandlerSaga: Saga = { action async in
    do {
        let handler = PrinterHandler.shared
        try handler.prepare()
    } catch {
        print(error)
    }
}

private let startScanSaga: Saga = { action async in
    guard let action = action as? StartScanDevices else {
        return
    }
    
    do {
        let handler = PrinterHandler.shared
        try handler.startScan()
    } catch {
        
    }
}

private let stopScanSaga: Saga = { action async in
    guard let action = action as? StopScanDevices else {
        return
    }
    
    do {
        let handler = PrinterHandler.shared
        try handler.stopScan()
    } catch {
        
    }
}

private let runPrintJobsSaga: Saga = { action async in
    guard let action = action as? RunPrintJobs else {
        return
    }
    
    guard let device = PrinterSelectors.selectPrinterDeviceInfo(stare: appStore.state) else {
        return
    }
    
    do {
        let handler = PrinterHandler.shared
        try await handler.run(device: device, transaction: action.jobs)
    } catch {
        
    }
}

