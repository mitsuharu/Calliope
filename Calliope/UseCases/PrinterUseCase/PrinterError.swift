//
//  PrinterError.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/04/19.
//

import Foundation

enum PrinterError: Error {
    case instanceFailed
    case langJaFailed
    case scanFailed
    case connectFailed
    case disconnectFailed
    case sendDataFailed
}
