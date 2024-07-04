//
//  ToastSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let toastSaga: Saga = { _ in
    await takeEvery(ToastActions.Show.self, saga: showToastSaga)
    await takeEvery(ToastActions.Dismiss.self, saga: dismissToastSaga)
}

private let showToastSaga: Saga = { action async in
    guard let action = action as? ToastActions.Show else {
        return
    }
    
    // 利用する Toast の不具合か？
    // .loading と併用するとtoastが閉じれなくなるので、別々に管理する
    await LoadingViewModel.shared.dismiss()
    
    let toastViewModel = ToastViewModel.shared
    await toastViewModel.showToast(
        message: action.message,
        subMessage: action.subMessage,
        type: action.type
    )
}

private let dismissToastSaga: Saga = { action async in
    guard let action = action as? ToastActions.Dismiss else {
        return
    }
    let toastViewModel = ToastViewModel.shared
    await toastViewModel.dismiss()
}
