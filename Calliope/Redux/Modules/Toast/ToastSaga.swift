//
//  ToastSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let toastSaga: Saga = { _ in
    await takeEvery(ToastActions.ShowToast.self, saga: showToastSaga)
    await takeEvery(ToastActions.ShowLoading.self, saga: showLoadingSaga)
    await takeEvery(ToastActions.dissmissToast.self, saga: dismissToastSaga)
}

let showToastSaga: Saga = { action async in
    guard let action = action as? ToastActions.ShowToast else {
        return
    }
    
    let toastViewModel = ToastViewModel.shared
    await toastViewModel.showToast(
        message: action.message,
        subMessage: action.subMessage,
        type: action.type
    )
}

let showLoadingSaga: Saga = { action async in
    guard let action = action as? ToastActions.ShowLoading else {
        return
    }
    
    let toastViewModel = ToastViewModel.shared
    if toastViewModel.showToast {
        await toastViewModel.dismiss()
    }
    
    await toastViewModel.showLoading(message: action.message)
}

let dismissToastSaga: Saga = { action async in
    guard let action = action as? ToastActions.dissmissToast else {
        return
    }
    
    let toastViewModel = ToastViewModel.shared
    await toastViewModel.dismiss()
}
