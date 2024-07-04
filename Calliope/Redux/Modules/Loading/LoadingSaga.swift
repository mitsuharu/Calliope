//
//  LoadingSaga.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwiftSaga

let loadingSaga: Saga = { _ in
    await takeEvery(LoadingActions.Show.self, saga: showSaga)
    await takeEvery(LoadingActions.Dissmiss.self, saga: dismissSaga)
}

private let showSaga: Saga = { action async in
    guard let action = action as? LoadingActions.Show else {
        return
    }
    
    // 利用する Toast の不具合か？
    // .loading と併用するとtoastが閉じれなくなるので、別々に管理する
    await ToastViewModel.shared.dismiss()
    
    await LoadingViewModel.shared.show(message: action.message)
}

private let dismissSaga: Saga = { action async in
    guard let action = action as? LoadingActions.Dissmiss else {
        return
    }
    
    await LoadingViewModel.shared.dismiss()
}
