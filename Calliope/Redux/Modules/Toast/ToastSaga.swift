//
//  ToastSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let toastSaga: Saga = { _ in
    await takeEvery(ShowToast.self, saga: showToastSaga)
}

let showToastSaga: Saga = { action async in
    guard let action = action as? ShowToast else {
        return
    }
    
    let toastViewModel = ToastViewModel.shared
    await toastViewModel.showToast(message: action.message)
}
