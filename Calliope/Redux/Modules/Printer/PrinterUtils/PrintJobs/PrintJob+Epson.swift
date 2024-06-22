//
//  PrintJob+Epson.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension Epos2Printer {
    
    func addPrinterOrder(order: Print.Job) {
        switch order {
        case .initialize:
            self.addCommand(EpsonEscPosCommond.initialize())
            
        case .text(let text, let size, let style):
            
            if let size = size {
                addPrinterOrderTextSize(size: size)
            }
            if let style = style {
                setPrinterOrderTextStyle(style: style)
            }
            
            self.addText("\(text)\n")
            
            if let _ = size {
                addPrinterOrderTextSize(size: .normal)
            }
            if let _ = style {
                setPrinterOrderTextStyle(style: .normal)
            }
            
        case .feed(let count):
            self.addFeedLine(count)
            
        case .rawCommond(let data):
            self.addCommand(data)
            
        case .textSize(size: let size):
            addPrinterOrderTextSize(size: size)
            
        case .textStyle(style: let style):
            setPrinterOrderTextStyle(style: style)
            
        case .qrCode(let text):
            self.addSymbol(
                text,
                type: EPOS2_SYMBOL_QRCODE_MODEL_2.rawValue,
                level: EPOS2_LEVEL_M.rawValue,
                width: 8,
                height: 8,
                size: 0)
            
            // // ESC/POSで印刷する場合
            // self.addCommand(EpsonEscPosCommond.qrCode(text: text))
            
        case .image(let image, let imageWidth):
            let width = CGFloat(imageWidth.rawValue)
            let size = CGSize(
                width: width,
                height: ((image.size.height / image.size.width) * width).rounded()
            )
            let resizedImage = image.resized(size: size)
            self.add(
                resizedImage,
                x: 0,
                y: 0,
                width: Int(size.width),
                height: Int(size.height),
                color: EPOS2_PARAM_DEFAULT,
                mode: EPOS2_MODE_MONO.rawValue,
                halftone: EPOS2_PARAM_DEFAULT,
                brightness: Double(EPOS2_PARAM_DEFAULT),
                compress: EPOS2_PARAM_DEFAULT
            )
            
            // ESC/POSで印刷する場合
            // self.addCommand(EpsonEscPosCommond.image(image: image, imageWidth: imageWidth.rawValue))
            
        }
    }
}

fileprivate extension Epos2Printer {
    
    func setPrinterOrderTextStyle(style: Print.Job.TextStyle) {
        switch style {
        case .normal:
            setBold(isBold: false)
        case .bold:
            setBold(isBold: true)
        }
    }
    
    func setBold(isBold: Bool) {
        self.addTextStyle(
            EPOS2_FALSE,
            ul: EPOS2_FALSE,
            em: isBold ? EPOS2_TRUE : EPOS2_FALSE,
            color: EPOS2_COLOR_1.rawValue
        )
    }
    
    func addPrinterOrderTextSize(size: Print.Job.TextSize) {
        switch size {
        case .normal:
            self.addTextSize(1, height: 1)
        case .scale(let width, let height):
            if width < 1 || 8 < width || height < 1 || 8 < height {
                self.addTextSize(1, height: 1)
            }
            self.addTextSize(width, height: height)
        }
    }
}
