//
//  MainViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation
import ReSwift

final class MainViewModel: ObservableObject, StoreSubscriber {
    typealias StoreSubscriberStateType = (
        name: String?,
        uuid: String?
    )
    
    @Published var name: String? = nil
    @Published var uuid: String? = nil
    
    let sampleCommonds: [SampleCommond] = MainViewModel.mekeSampleCommonds()
    
    init() {
        appStore.subscribe(self) {
            $0.select { (
                selectPrinterName(stare: $0),
                selectPrinterUUID(stare: $0)
            ) }
        }
    }
    
    deinit {
        appStore.unsubscribe(self)
    }
    
    func newState(state: StoreSubscriberStateType) {
        Task { @MainActor in
            self.name = state.name
            self.uuid = state.uuid
        }
    }
}

extension MainViewModel {
    
    struct SampleCommond {
        let title: String
        let action: () -> Void
        let uuid = UUID().uuidString
    }
    
    fileprivate static func mekeSampleCommonds() -> [SampleCommond] {
        
        var commonds: [SampleCommond] = []
        
        let commond1 = SampleCommond(title: "テキストの印刷") {
            let orders: [Print.Instruction] = [
                .text(text: "hello"),
                .text(text: "こんにちはコンニチワ今日わ"),
                .feed(count: 1),
                .text(text: "http://www.example.com"),
                .qrCode(text: "http://www.example.com")
            ]
            appStore.dispatch(onMain: RunPrintInstruction(instructions: orders))
        }
        commonds.append(commond1)
        
        if let image = UIImage(named: "himawari.jpg") {
            let commond2 = SampleCommond(title: "画像の印刷") {
                let orders: [Print.Instruction] = [
                    .text(text: "ひまわり"),
                    .feed(count: 1),
                    .image(image: image),
                    .feed(count: 1)
                ]
                appStore.dispatch(onMain: RunPrintInstruction(instructions: orders))
            }
            commonds.append(commond2)
        }
        
//        if let image = UIImage(named: "himawari.jpg") {
//            let orders: [Print.Instruction] = [
//                .text(text: "ひまわり"),
//                .feed(count: 1),
//                .image(image: image),
//                .feed(count: 1),]
//            appStore.dispatch(onMain: RunPrinterOrder(orders: orders))
//        }
//
//        let orders: [PrinterOrder] = [
//            .text(text: "hello"),
//            .text(text: "こんにちはコンニチワ今日わ"),
//            .feed(count: 1),
//            .text(text: "http://www.example.com"),
//            .qrCode(text: "http://www.example.com")]
//        appStore.dispatch(onMain: RunPrinterOrder(orders: orders))
        
        return commonds
        
    }
}
