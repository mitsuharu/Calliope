//
//  UIImage+Binary.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/07/05.
//

import Foundation

extension UIImage {
    
    func convertBinaryOneBitBitmap(size: CGSize) -> OneBitBitmap? {
        
        // 幅を8倍に調整する
        let width = Int(ceil(Double(size.width) / 8.0) * 8.0)
        let height = Int(size.height)
        
        // 画像をリサイズ
        let resizedImage = self.resized(size: CGSize(width: width, height: height))
        
        guard let cgImage = resizedImage.cgImage else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = calloc(height * width * 4, MemoryLayout<UInt8>.size)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let context = CGContext(
            data: rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage,
                     in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let rawData = rawData else { return nil }
        let pixelData = rawData.bindMemory(to: UInt8.self, capacity: height * width * 4)
        
        // 閾値 127
        let threshold = 140
        
        var data = [UInt8](repeating: 0, count: height * width / 8)
        var index = 0
        for y in 0..<height {
            for x in stride(from: 0, to: width, by: 8) {
                var part = [UInt8](repeating: 0, count: 8)
                for j in 0..<8 {
                    let readWidth = x + j >= width ? width - 1 : x + j
                    let pixelIndex = (y * width + readWidth) * 4
                    let r = pixelData[pixelIndex]
                    let g = pixelData[pixelIndex + 1]
                    let b = pixelData[pixelIndex + 2]
                    let gray = Int(Double(r) * 0.3 + Double(g) * 0.59 + Double(b) * 0.11)
                    part[j] = gray > threshold ? 0 : 1
                }
                let temp = part[0] << 7 | part[1] << 6 | part[2] << 5 | part[3] << 4 | part[4] << 3 | part[5] << 2 | part[6] << 1 | part[7]
                data[index] = temp
                index += 1
            }
        }
        
        free(rawData)
        
        let result = OneBitBitmap(
            data: data,
            width: width,
            height: height
        )
        return result
    }
    
    
}
