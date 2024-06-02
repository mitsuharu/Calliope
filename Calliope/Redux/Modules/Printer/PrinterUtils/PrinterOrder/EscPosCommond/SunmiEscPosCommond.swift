//
//  SunmiEscPosCommond.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/02.
//

import Foundation

struct SunmiEscPosCommond: EscPosCommondProtocol {
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
    
    static func textScale(scale: EscPosCommond.TextScale) -> Data {
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=34
        
        let width = scale.width
        let height = scale.height
        
        if width < 1 || 8 < width || height < 1 || 8 < height {
            return Data([0x1D, 0x21, 0x00])
        }
        let widthScale = UInt8(16 * (width - 1))
        let heightScale = UInt8(height - 1)
        return Data([0x1D, 0x21, (widthScale + heightScale)])
    }
    
    static func textStyle(style: EscPosCommond.TextStyle) -> Data {
        switch style {
        case .normal:
            return SunmiEscPosCommond.bold(isBold: false)
        case .bold:
            return SunmiEscPosCommond.bold(isBold: true)
        }
    }
    
    static func bold(isBold: Bool) -> Data {
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=25
        return Data([0x1b, 0x45, isBold ? 0x01 : 0x00])
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
        // sunmi では動作未確認
        
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
    
    static func image(image: UIImage) -> Data {
        
        let width: Int = 200 //384 // 固定
        let height: Int = Int((image.size.height / image.size.width) * CGFloat(width))
        let targetSize = CGSize(width: width, height: height)
        
        guard let oneBitBitmap = image.convertOneBitBitmap(size: targetSize) else {
            return Data()
        }
        
        var data = Data()
        data.append(contentsOf: [0x1D, 0x76, 0x30])
        data.append(contentsOf: [0])

        let xL = UInt8((oneBitBitmap.width / 8) % 256)
        let xH = UInt8((oneBitBitmap.width / 8) / 256)
        let yL = UInt8(oneBitBitmap.height % 256)
        let yH = UInt8(oneBitBitmap.height / 256)
        data.append(contentsOf: [xL, xH, yL, yH])
                
        data.append(contentsOf: oneBitBitmap.data)

        return data
    }

    
}
