//
//  EscPosCommond.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/05.
//

import Foundation

extension Print.Instruction {
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
        static func image(image: UIImage) -> Data
    }
}



struct EscPosCommond: Print.Instruction.EscPosCommondProtocol {

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
    
    static func textSize(size: Print.Instruction.TextSize) -> Data {
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
    
    static func textStyle(style: Print.Instruction.TextStyle) -> Data {
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
    
    static func image(image: UIImage) -> Data {
        
        let width: CGFloat = 200 //384 // 固定
        let height: CGFloat = (image.size.height / image.size.width) * width
        let size = CGSize(width: width, height: height.rounded(.up))
                
        guard let bitmapData = image.makeBitmap(width: size.width) else {
            print("Error converting image")
            return Data()
        }
                
        print("bitmapData: \(bitmapData)")
        print("bitmapData.count: \(bitmapData.count)")
        print("size: \(size), ")
        
        let byteCount2 = 256
        let byteCount3 = 65536
        let byteCount4 = 16777216
        
        let p1 = bitmapData.count % byteCount2
        let p2 = (bitmapData.count / byteCount2) % byteCount2
        let p3 = (bitmapData.count / byteCount3) % byteCount2
        let p4 = (bitmapData.count / byteCount4) % byteCount2
        
        print("p1: \(p1), p2: \(p2), p3: \(p3), p4: \(p4), ")
                
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=99#gs_lparen_cl_fn112

        let xL = Int(size.width) % 256
        let xH = (Int(size.width) / 256 ) % 256
        let yL = Int(size.height) % 256
        let yH = (Int(size.height) / 256 ) % 256
        
        var command = Data()
        
        // 画像を一旦バッファーに格納する
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=98
        command.append(contentsOf: [0x1D, 0x28, 0x4C])
        
        // データの長さを計算して追加 (pL, pH)
        let totalSize = bitmapData.count + 16  // ヘッダー + ビットマップデータの長さ
        command.append(UInt8(totalSize % 256))
        command.append(UInt8(totalSize / 256))
        
        // コマンドの設定
        command.append(0x30) // fn (画像データの転送)
        command.append(0x70) // m (通常の印刷モード)
        command.append(48) // 00) // a データの階調 48 モノクロ (2階調)
        command.append(0x01) // bx (横方向の拡大率)
        command.append(0x01) // by (縦方向の拡大率)
        command.append(49) // 01) // c (グラフィックスデータの色) 第1色
        
        // 画像の幅と高さ
        command.append(contentsOf: [UInt8(xL), UInt8(xH), UInt8(yL), UInt8(yH)])
        
        print("commandData: \(command), ")
        
        command.append(contentsOf: bitmapData)
        
        // https://www.epson-biz.com/modules/ref_escpos_ja/index.php?content_id=98
        command.append(contentsOf: [0x1d, 0x28, 0x4c, 0x02, 0x00, 0x30, 50])
        
        command.append(0x0a)
        
        return command
    }
    

    // sunmi 用
    static func printImage(image: UIImage) -> Data {
        
        let width: Int = 200 //384 // 固定
        let height: Int = Int((image.size.height / image.size.width) * CGFloat(width))
        let targetSize = CGSize(width: width, height: height)
        
        guard let imageData = image.imageFileToEsc(targetSize: targetSize) else {
            return Data()
        }
        return Data(imageData)
    }

}


fileprivate extension UIImage {
    
    func imageFileToEsc(targetSize: CGSize) -> [UInt8]? {
        
        guard let oneBitBitmap = self.convertOneBitBitmap(size: targetSize) else {
            return nil
        }
        
        var data = [UInt8]()
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
