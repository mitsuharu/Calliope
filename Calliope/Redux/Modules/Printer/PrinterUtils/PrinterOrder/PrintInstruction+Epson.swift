//
//  PrinterOrder+Epson.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension Epos2Printer {
    
    func addPrinterOrder(order: Print.Instruction) {
        switch order {
        case .initialize:
            self.addCommand(EpsonEscPosCommond.initialize())
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
            self.addCommand(EpsonEscPosCommond.qrCode(text: text))
        case .image(let image):
            
            let width: Int = 200 //384 // 固定
            let height: Int = Int( (image.size.height / image.size.width) * CGFloat(width))
            
            let resizedImage = image.resize(width: CGFloat(width))
                
            self.add(
                resizedImage,
                x: 0,
                y: 0,
                width: 200,
                height: height,
                color: -2,
                mode: 0,
                halftone: -2,
                brightness: 1.0,
                compress: -2
            )
                
            /*
             - (int) addImage:(UIImage *)data x:(long)x y:(long)y width:(long)width height:(long)height color:(int)color mode:(int)mode halftone:(int)halftone brightness:(double)brightness compress:(int)compress;
             */
            
//            self.addCommand(EpsonEscPosCommond.image(image: image))
        }
    }
}

fileprivate extension Epos2Printer {
    
    func setPrinterOrderTextStyle(style: Print.Instruction.TextStyle) {
        switch style {
        case .normal:
            self.setBold(isBold: false)
        case .bold:
            self.setBold(isBold: true)
        }
    }
    
    func setBold(isBold: Bool) {
        self.addTextStyle(EPOS2_FALSE, 
                          ul: EPOS2_FALSE,
                          em: isBold ? EPOS2_TRUE : EPOS2_FALSE,
                          color: EPOS2_COLOR_1.rawValue)
    }
    
    func addPrinterOrderTextSize(size: Print.Instruction.TextSize) {
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
