//
//  EscPosCommond.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension PrinterOrder {
    /**
     ESC/POS コマンドのプロトコル（各社で方言があるのでメーカー別に作るかもでプロトコルにした）
     */
    protocol EscPosCommondProtocol {
        static func initialize() -> Data
        static func text(text: String) -> Data
        static func textSize(size: TextSize) -> Data
        static func textStyle(style: TextStyle) -> Data
        static func bold(isBold: Bool) -> Data
        static func feed() -> Data
        static func feed(count: Int) -> Data
        static func qrCode(text: String) -> Data
    }
}


struct EscPosCommond: PrinterOrder.EscPosCommondProtocol {

    private init() {}
    
    static func initialize() -> Data {
        Data([0x1b, 0x40])
    }
    
    static func text(text: String) -> Data {
        var date = Data()
        if let d = text.data(using: .shiftJIS) {
            date.append(d)
            date.append(0x0a)
        }
        return date
    }
    
    static func textSize(size: PrinterOrder.TextSize) -> Data {
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=34
        switch size {
        case .normal:
            return Data([0x1D, 0x21, 0x00])
        case.double:
            return Data([0x1D, 0x21, 0x11])
        case.widthDouble:
            return Data([0x1D, 0x21, 0x10])
        case.heightDouble:
            return Data([0x1D, 0x21, 0x01])
        case .scale(let width, let height):
            if width < 1 || 8 < width || height < 1 || 8 < height {
                return textSize(size: .normal)
            }
            let w = UInt8(16 * (width - 1))
            let h = UInt8(height - 1)
            return Data([0x1D, 0x21, w+h])
        }
    }
    
    static func textStyle(style: PrinterOrder.TextStyle) -> Data {
        switch style {
        case .normal:
            return EscPosCommond.bold(isBold: false)
        case .bold:
            return EscPosCommond.bold(isBold: true)
        }
    }
    
    static func bold(isBold: Bool) -> Data {
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=25
        if isBold {
            return Data([0x1b, 0x45, 0x01])
        } else {
            return Data([0x1b, 0x45, 0x00])
        }
    }
    static func feed() -> Data {
        Data([0x1b, 0x64, UInt8(5)])
    }
    
    static func feed(count: Int) -> Data {
        Data([0x1b, 0x64, UInt8(count)])
    }
    
    /**
     EPSON では印刷できるが、SUNMIでは印刷できない
     */
    static func qrCode(text: String) -> Data {
        
        var result = Data()
        
        // QRコードのモデル設定
        let modelCommand = Data([0x1d, 0x28, 0x6b, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00])
        result.append(modelCommand)

        // QRコードのサイズ設定
        let sizeCommand = Data([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x43, 0x08])
        result.append(sizeCommand)

        // QRコードのエラー訂正レベル設定
        let errorCorrectionCommand = Data([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x45, 0x33])
        result.append(errorCorrectionCommand)

        // QRコードデータの追加
        let pL = UInt8((text.count + 3) % 256)
        let pH = UInt8((text.count + 3) / 256)
        var storeCommand = Data([0x1d, 0x28, 0x6b, pL, pH, 0x31, 0x50, 0x30])
        storeCommand.append(text.data(using: .ascii)!)
        result.append(storeCommand)

        // QRコードの印刷命令
        let printCommand = Data([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x51, 0x30])
        result.append(printCommand)
        
        return result
    }
    
}
