//
//  PrinterOrder.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

enum PrinterOrder {
    case text(text: String, size: TextSize? = nil, style: TextStyle? = nil)
    case textSize(size: TextSize)
    case textStyle(style: TextStyle)
    case feed(count: Int)
    case qrCode(text: String)
    case escPosCommond(data: Data)
}

extension PrinterOrder {
    
    enum TextStyle {
        case normal
        case bold
    }
    
    enum TextSize {
        case normal
        case widthDouble
        case heightDouble
        case double
        
        /**
         width と height はともに 1 ~ 8 まで設定できます
         */
        case scale(width: Int, height: Int)
    }
    
}
