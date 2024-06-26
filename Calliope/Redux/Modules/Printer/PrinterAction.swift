//
//  PrinterAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

protocol PrinterAction: Action {}

enum PrinterActions {
    
    struct AssignPrinterDeviceInfo: PrinterAction {
        let deviceInfo: PrinterDeviceInfo
    }
    
    struct AssignPrinterCandiates: PrinterAction {
        let candiates: Set<PrinterDeviceInfo>
    }
    
    struct AppendPrinterCandiate: PrinterAction {
        let candiate: PrinterDeviceInfo
    }
    
    struct StartScanDevices: PrinterAction {
    }
    
    struct StopScanDevices: PrinterAction {
    }
    
    struct RunPrintJobs: PrinterAction {
        let jobs: [Print.Job]
    }
    
    struct AppendBuildJobs: PrinterAction {
        let buildJob: PrinterState.BuildJob
    }
    
    struct DeleteBuildJobs: PrinterAction {
        let buildJob: PrinterState.BuildJob
    }
    
}
