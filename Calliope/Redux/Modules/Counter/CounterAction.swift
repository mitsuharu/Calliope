//
//  CounterAction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import Foundation
import ReSwift

protocol CounterAction: Action {}

struct Increase: CounterAction {}
struct Decrease: CounterAction {}
struct Assign: CounterAction {
    let count: Int
}
struct Clear: CounterAction {}


