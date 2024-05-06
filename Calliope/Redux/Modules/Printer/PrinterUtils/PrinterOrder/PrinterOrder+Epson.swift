//
//  PrinterOrder+Epson.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension Epos2Printer {
    
    func addPrinterOrder(order: PrinterOrder) {
        switch order {
        case .text(let text, let size, let style):
            
            if let size = size {
                self.addPrinterOrderTextSize(size: size)
            }
            if let style = style {
                setPrinterOrderTextStyle(style: style)
            }

            self.addText("\(text)\n")
            
            if let _ = size {
                self.addTextSize(1, height: 1)
            }
            if let _ = style {
                setPrinterOrderTextStyle(style: .normal)
            }

        case .feed(let count):
            self.addFeedLine(count)
        case .escPosCommond(let data):
            self.addCommand(data)
        case .textSize(size: let size):
            self.addPrinterOrderTextSize(size: size)
        case .textStyle(style: let style):
            self.setPrinterOrderTextStyle(style: style)
        case .qrCode(let text):
            self.addCommand(EscPosCommond.qrCode(text: text))
        case .image(let image):
            self.addCommand(EscPosCommond.image(image: image))
        }
    }
    
    private func setPrinterOrderTextStyle(style: PrinterOrder.TextStyle) {
        switch style {
        case .normal:
            self.setBold(isBold: false)
        case .bold:
            self.setBold(isBold: true)
        }
    }
    
    private func setBold(isBold: Bool) {
        self.addTextStyle(EPOS2_FALSE, 
                          ul: EPOS2_FALSE,
                          em: isBold ? EPOS2_TRUE : EPOS2_FALSE,
                          color: EPOS2_COLOR_1.rawValue)
    }
    
    private func addPrinterOrderTextSize(size: PrinterOrder.TextSize) {
        switch size {
        case .normal:
            self.addTextSize(1, height: 1)
        case.double:
            self.addTextSize(2, height: 2)
        case.widthDouble:
            self.addTextSize(2, height: 1)
        case.heightDouble:
            self.addTextSize(1, height: 2)
        case .scale(let width, let height):
            if width < 1 || 8 < width || height < 1 || 8 < height {
                self.addTextSize(1, height: 1)
            }
            self.addTextSize(width, height: height)
        }
    }
}
