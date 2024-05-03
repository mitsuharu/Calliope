//
//  CounterSelectors.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation

func selectCount(store: AppState) -> Int {
    store.counter.count
}
