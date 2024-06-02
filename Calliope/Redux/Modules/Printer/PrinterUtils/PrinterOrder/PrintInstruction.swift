//
//  PrintInstruction.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

enum Print {
    
    /**
     製造会社
     */
    enum Manufacturer {
        case epson
        case sunmi
    }
    
    /**
     印刷命令
     */
    enum Instruction {
        case initialize
        case text(text: String, size: TextSize? = nil, style: TextStyle? = nil)
        case textSize(size: TextSize)
        case textStyle(style: TextStyle)
        case feed(count: Int)
        case qrCode(text: String)
        case escPosCommond(data: Data)
        case image(image: UIImage)
    }
}

//enum PrinterOrder {
//    case text(text: String, size: TextSize? = nil, style: TextStyle? = nil)
//    case textSize(size: TextSize)
//    case textStyle(style: TextStyle)
//    case feed(count: Int)
//    case qrCode(text: String)
//    case escPosCommond(data: Data)
//    case image(image: UIImage)
//}

extension Print.Instruction {
    
    enum TextStyle {
        case normal
        case bold
    }
    
    enum TextSize {
        case normal

        /**
         width と height はともに 1 ~ 8 まで設定できます
         */
        case scale(width: Int, height: Int)
    }
    
}
