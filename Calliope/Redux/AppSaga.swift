//
//  AppSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let appSage: Saga = { _ async in
    do {
        try await fork(toastSaga)
        try await fork(loadingSaga)
        try await fork(printerSaga)
    } catch {
        print(error)
    }
}
