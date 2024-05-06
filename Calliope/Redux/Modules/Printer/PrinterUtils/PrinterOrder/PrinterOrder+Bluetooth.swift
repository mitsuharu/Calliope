//
//  PrinterOrder+Command.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension PrinterOrder {
    
    var bluetoothCommand: Data {
        get {
            switch self {
            case .text(let text, let size, let style):
                var data = Data()
                
                if let size = size {
                    data.append(EscPosCommond.textSize(size: size))
                }
                if let style = style {
                    data.append(EscPosCommond.textStyle(style: style))
                }
                
                data.append(EscPosCommond.text(text: text))
                
                if let _ = size {
                    data.append(EscPosCommond.textSize(size: .normal))
                }
                if let _ = style {
                    data.append(EscPosCommond.textStyle(style: .normal))
                }
                
                return data
            case .feed(let count):
                return EscPosCommond.feed(count: count)
            case .escPosCommond(let data):
                return data
            case .textSize(size: let size):
                return EscPosCommond.textSize(size: size)
            case .textStyle(style: let style):
                return EscPosCommond.textStyle(style: style)
            case .qrCode(let text):
                return EscPosCommond.qrCode(text: text)
            case .image(let image):
                return EscPosCommond.image(image: image)
            }
        }
    }
    
}
