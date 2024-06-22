//
//  ScanViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import ReSwift

final class ScanViewModel: ObservableObject, StoreSubscriber {    
    typealias StoreSubscriberStateType = (
        hasCandiates: Bool,
        manufacturerCandiates: [PrinterDeviceInfo.Manufacturer: [PrinterDeviceInfo]]
    )
    
    @Published var hasCandiates: Bool = false
    @Published var manufacturerCandiates: [PrinterDeviceInfo.Manufacturer: [PrinterDeviceInfo]] = [:]
    
    init() {
        print("ScanViewModel init")
        appStore.subscribe(self) {
            $0.select {(
                PrinterSelectors.selectPrinterCandiatesExist(stare: $0),
                PrinterSelectors.selectPrinterManufacturerCandiates(stare: $0)
                )
            }
        }
        appStore.dispatch(onMain: StartScanDevices())
    }
    
    deinit {
        appStore.unsubscribe(self)
        appStore.dispatch(onMain: StopScanDevices())
    }
    
    func newState(state: StoreSubscriberStateType) {
        Task { @MainActor in
            self.hasCandiates = state.hasCandiates
            self.manufacturerCandiates = state.manufacturerCandiates
        }
    }
    
    func selectCandiate(deviceInfo: PrinterDeviceInfo) {
        appStore.dispatch(onMain: AssignPrinterDeviceInfo(deviceInfo: deviceInfo))
        NavigationRouter.shared.goBack()
    }
}
