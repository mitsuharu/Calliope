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
        appStore.unsubscribe(self)
    }
    
    func newState(state: StoreSubscriberStateType) {
        Task { @MainActor in
            self.name = state.name
            self.uuid = state.uuid
            
            if self.buildJobs != state.buildJobs {
                self.buildJobs = state.buildJobs
            }
        }
    }
    
    func run(jobs: [Print.Job]) {
        appStore.dispatch(onMain: PrinterActions.RunPrintJobs(jobs: jobs))
    }
    
    func runBuildJob(buildJob: PrinterState.BuildJob) {
        run(jobs: buildJob.jobs)
    }
    
    func deleteBuildJob(buildJob: PrinterState.BuildJob) {
        appStore.dispatch(onMain: PrinterActions.DeleteBuildJobs(buildJob: buildJob))
    }
}
