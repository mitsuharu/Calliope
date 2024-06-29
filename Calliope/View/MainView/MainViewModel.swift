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
        uuid: String?,
        buildJobs: [PrinterState.BuildJob]
    )
    
    @Published var name: String? = nil
    @Published var uuid: String? = nil
    @Published var buildJobs: [PrinterState.BuildJob] = []
    
    var sampleCommonds: [SampleCommond] = []
    
    init() {
        print("MainViewModel#init")
        appStore.subscribe(self) {
            $0.select { (
                PrinterSelectors.selectPrinterName(stare: $0),
                PrinterSelectors.selectPrinterUUID(stare: $0),
                PrinterSelectors.selectBuildJobs(stare: $0)
            ) }
        }
        
        sampleCommonds = mekeSampleCommonds()
    }
    
    deinit {
        print("MainViewModel#deinit")
        appStore.unsubscribe(self)
    }
    
    func newState(state: StoreSubscriberStateType) {
        Task { @MainActor in
            self.name = state.name
            self.uuid = state.uuid
            self.buildJobs = state.buildJobs
        }
    }
    
    func run(jobs: [Print.Job]) {
        if (uuid?.isEmpty ?? true) == true {
            return
        }
        appStore.dispatch(onMain: PrinterActions.RunPrintJobs(jobs: jobs))
    }
    
    func runBuildJobs(buildJob: PrinterState.BuildJob) {
        run(jobs: buildJob.jobs)
    }
}

extension MainViewModel {
    
    struct SampleCommond {
        let title: String
        let jobs: [Print.Job]
        let uuid = UUID().uuidString
    }
        
    fileprivate func mekeSampleCommonds() -> [SampleCommond] {
        
        var commonds: [SampleCommond] = []
        
        let commond1 = SampleCommond(
            title: "テキストの印刷",
            jobs: [
                .text(text: "Hello World!"),
                .text(text: "日本語も印刷デキます。"),
                .feed(count: 1),
            ]
        )
        commonds.append(commond1)
        
        if let image = UIImage(named: "himawari.jpg") {
            let commond2 = SampleCommond(
                title: "画像の印刷",
                jobs: [
                    .text(text: "ひまわり"),
                    .feed(count: 1),
                    .image(image: image),
                    .feed(count: 1)
                ]
            )
            commonds.append(commond2)
        }
        
        let commond3 = SampleCommond(
            title: "QRコードの印刷",
            jobs: [
                .text(text: "QRコードで「http://www.example.com」を印刷します"),
                .qrCode(text: "http://www.example.com"),
                .feed(count: 1),
            ]
        )
        commonds.append(commond3)
        
        return commonds
        
    }
}
