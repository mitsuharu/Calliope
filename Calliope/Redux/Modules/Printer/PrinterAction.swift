//
//  PrinterAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

protocol PrinterAction: Action {}

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

struct RunPrinterOrder: PrinterAction {
    let orders: [Print.Instruction]
}
