//
//  PrintJob+Sunmi.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension Print.Job {
    
    var sunmiEscPosCommand: Data {
        get {
            switch self {
            case .initialize:
                return SunmiEscPosCommond.initialize()
            case .text(let text, let size, let style):
                var data = Data()
                
                if let size = size {
                    data.append(scaleCommond(size))
                }
                if let style = style {
                    data.append(styleCommond(style))
                }
                
                data.append(SunmiEscPosCommond.text(text: text))
                
                if let _ = size {
                    data.append(scaleCommond(.normal))
                }
                if let _ = style {
                    data.append(styleCommond(.normal))
                }
                
                return data
            case .feed(let count):
                return SunmiEscPosCommond.feed(count: count)
            case .rawCommond(let data):
                return data
            case .textSize(size: let size):
                return scaleCommond(size)
            case .textStyle(style: let style):
                return styleCommond(style)
            case .qrCode(let text):
                return SunmiEscPosCommond.qrCode(text: text)
            case .image(let image, let imageWidth):
                if let image = self.image() {
                    return SunmiEscPosCommond.image(image:image, imageWidth: imageWidth.rawValue)
                }
                return Data()
            }
        }
    }
    
}

fileprivate extension Print.Job {
    
    private func scaleCommond(_ size: Print.Job.TextSize) -> Data {
        switch size {
        case .normal:
            let scale = EscPosCommond.TextScale(width: 1, height: 1)
            return SunmiEscPosCommond.textScale(scale: scale)
        case .scale(let width, let height):
            let scale = EscPosCommond.TextScale(width: width, height: height)
            return SunmiEscPosCommond.textScale(scale: scale)
        }
    }
    
    private func styleCommond(_ style: Print.Job.TextStyle) -> Data {
        switch style {
        case .normal:
            return SunmiEscPosCommond.textStyle(style: .normal)
        case .bold:
            return SunmiEscPosCommond.textStyle(style: .bold)
        }
    }
}
