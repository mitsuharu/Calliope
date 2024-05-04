//
//  ScanViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import ReSwift

final class ScanViewModel: ObservableObject, StoreSubscriber {
    typealias StoreSubscriberStateType = [PrinterDeviceInfo]
    
    @Published var candiates: [PrinterDeviceInfo] = []
    
    init() {
        print("ScanViewModel init")
        appStore.subscribe(self) {
            $0.select {
                selectPrinterCandiates(store: $0)
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
            self.candiates = state
        }
    }
    
    func selectCandiate(deviceInfo: PrinterDeviceInfo) {
        appStore.dispatch(onMain: AssignPrinterDeviceInfo(deviceInfo: deviceInfo))
        NavigationRouter.shared.goBack()
    }
}
