//
//  PrinterReducer.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

func printerReducer(action: PrinterAction, state: PrinterState) -> PrinterState {
    
    switch action {
    case let action as PrinterActions.AssignPrinterDeviceInfo:
        return PrinterState(deviceInfo: action.deviceInfo, candiates: nil, buildJobs: state.buildJobs)
        
    case let action as PrinterActions.AssignPrinterCandiates:
        return PrinterState(deviceInfo: state.deviceInfo, candiates: action.candiates, buildJobs: state.buildJobs)
        
    case let action as PrinterActions.AppendPrinterCandiate:
        
        var nextCandiates : Set<PrinterDeviceInfo> = (state.candiates ?? [])
        nextCandiates.insert(action.candiate)
        
        return PrinterState(
            deviceInfo: state.deviceInfo,
            candiates: nextCandiates,
            buildJobs: state.buildJobs
        )
        
    case let action as PrinterActions.AppendBuildJobs:
        
        var nextBuildJobs = state.buildJobs
        nextBuildJobs.append(action.buildJob)
        
        return PrinterState(
            deviceInfo: state.deviceInfo,
            candiates: state.candiates,
            buildJobs: nextBuildJobs
        )
        
    case let action as PrinterActions.DeleteBuildJobs:
        
        var nextBuildJobs = state.buildJobs
        if let index = nextBuildJobs.firstIndex(where: { job in
            job.id == action.buildJob.id
        }) {
            nextBuildJobs.remove(at: index)
        }
        return PrinterState(
            deviceInfo: state.deviceInfo,
            candiates: state.candiates,
            buildJobs: nextBuildJobs
        )
        
    default:
        return state
    }
}
