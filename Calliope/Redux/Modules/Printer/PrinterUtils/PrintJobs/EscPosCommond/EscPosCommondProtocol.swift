//
//  EscPosCommondProtocol.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

enum EscPosCommond {
    struct TextScale {
        let width: Int
        let height: Int
    }
    
    enum TextStyle {
        case normal
        case bold
    }
}

protocol EscPosCommondProtocol {
    static func initialize() -> Data
    static func text(text: String) -> Data
    static func textScale(scale: EscPosCommond.TextScale) -> Data
    static func textStyle(style: EscPosCommond.TextStyle) -> Data
    static func bold(isBold: Bool) -> Data
    static func feed() -> Data
    static func feed(count: Int) -> Data
    static func qrCode(text: String) -> Data
    static func image(image: UIImage) -> Data
}
