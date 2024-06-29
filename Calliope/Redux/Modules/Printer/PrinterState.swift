//
//  PrinterState.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

struct PrinterState {
    
    let deviceInfo: PrinterDeviceInfo?
    let candiates: Set<PrinterDeviceInfo>?
    var buildJobs: [PrinterState.BuildJob]
    
    static func initialState() -> PrinterState {
        PrinterState(
            deviceInfo: nil,
            candiates: nil,
            buildJobs: []
        )
    }
}

extension PrinterState: Hashable {
    
    struct BuildJob: Hashable {
        static func == (lhs: PrinterState.BuildJob, rhs: PrinterState.BuildJob) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        let id = UUID()
        let title: String
        let jobs: [Print.Job]
    }
}
