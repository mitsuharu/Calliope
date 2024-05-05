//
//  PrinterOrder.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

enum PrinterOrder {
    case text(text: String, size: Int = 20, style: TextStyle? = nil)
    case feed(count: Int)
    case escPosCommond(data: Data)
}

enum TextStyle {
    case normal
    case bold
    case italic
}
