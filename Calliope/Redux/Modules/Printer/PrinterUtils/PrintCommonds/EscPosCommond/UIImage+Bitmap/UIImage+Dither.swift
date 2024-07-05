//
//  UIImage+Dither.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/07/05.
//

import Foundation

extension UIImage {
        
    func convertDitherOneBitBitmap(size: CGSize) -> OneBitBitmap? {
        
        // 幅を8倍に調整する
        let width = Int(ceil(Double(size.width) / 8.0) * 8.0)
        let height = Int(size.height)
        
        // 画像をリサイズ
        let resizedImage = self.resized(size: CGSize(width: width, height: height))
        
        // グレイスケール化
        guard
            let grayscale = resizedImage.grayscaleImage(),
            let cgImage = grayscale.cgImage
        else {
            return nil
        }

        // グレースケール画像のバッファを準備
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return nil }
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
        
        // Floyd-Steinbergディザリングを実行し、1ビットビットマップデータを作成
        let threshold = 128
        for y in 0..<height {
            for x in 0..<width {
                let i = y * width + x
                let oldPixel = data[i]
                let newPixel: UInt8 = oldPixel < threshold ? 0 : 255
                data[i] = newPixel
                let quantError = Int(oldPixel) - Int(newPixel)
                
                if x + 1 < width {
                    data[i + 1] = UInt8(clamping: Int(data[i + 1]) + quantError * 7 / 16)
                }
                if y + 1 < height {
                    if x > 0 {
                        data[i + width - 1] = UInt8(clamping: Int(data[i + width - 1]) + quantError * 3 / 16)
                    }
                    data[i + width] = UInt8(clamping: Int(data[i + width]) + quantError * 5 / 16)
                    if x + 1 < width {
                        data[i + width + 1] = UInt8(clamping: Int(data[i + width + 1]) + quantError * 1 / 16)
                    }
                }
            }
        }
        
        // 1ビットビットマップデータを格納する配列を準備
        var bitmapData = [UInt8](repeating: 0, count: (width + 7) / 8 * height)
        
        // 1ビットビットマップデータを作成
        for y in 0..<height {
            for x in 0..<width {
                let i = y * width + x
                let bitIndex = x % 8
                let byteIndex = y * ((width + 7) / 8) + x / 8
                if data[i] == 0 {
                    bitmapData[byteIndex] |= (1 << (7 - bitIndex))
                }
            }
        }

        let result = OneBitBitmap(
            data: bitmapData,
            width: width,
            height: height
        )
        return result
    }
}
