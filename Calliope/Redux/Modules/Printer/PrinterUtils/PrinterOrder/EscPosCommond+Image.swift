//
//  EscPosCommond+Image.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/06.
//

import Foundation
import Bitmap

extension EscPosCommond {
    
    static func convertToGrayscaleBitmap(image: UIImage, size: CGSize) -> [UInt8]? {
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let scale = size.width / image.size.width
        
        do {
            let bitmap = try Bitmap(cgImage)
                .scaling(scale: scale)
                .grayscaling()
            print("bitmap.rgbaBytes.count: \(bitmap.rgbaBytes.count)")
            return bitmap.rgbaBytes
//            return Data(bitmap.rgbaBytes)
        } catch {
            return nil
        }
        
    }
}

extension UIImage {
    

    func resize(width: CGFloat) -> UIImage? {
        let size = self.size
        let heightRatio = width / size.width
        let targetHeight = size.height * heightRatio
        let targetSize = CGSize(width: width, height: targetHeight)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        print("self.size: \(self.size), resizedImage: \(resizedImage?.size)")
        
        return resizedImage
    }
    
    func convertToGrayscale() -> UIImage? {
        let context = CIContext(options: nil)
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        let beginImage = CIImage(image: self)
        filter.setValue(beginImage, forKey: kCIInputImageKey)

        if let output = filter.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func convertTo1BitBitmap() -> [UInt8]? {
        guard let cgImage = self.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bytesPerRow = (width + 7) / 8  // 1ビットデータのためのバイト数計算

        // 8ビットのグレースケールでビットマップコンテキストを作成
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return nil
        }

        // イメージをコンテキストに描画
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // 生成したイメージからデータを取得
        guard let data = context.data else { return nil }

        var bitmap = [UInt8](repeating: 0, count: bytesPerRow * height)
//        var bitmap = [UInt8](repeating: 0, count: width * height)
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * width + x
                let grayValue = data.load(fromByteOffset: offset, as: UInt8.self)
                if grayValue < 128 {  // 128を閾値として1ビット化
                    let index = y * bytesPerRow + x / 8
                    bitmap[index] |= (0x80 >> (x % 8))
                }
            }
        }
        
        print("bitmap.count: \(bitmap.count), width: \(width), height: \(height)")
        
        return bitmap
    }
    
    func makeBitmap(width: CGFloat) -> [UInt8]? {
        guard
            let resized = self.resize(width: width),
            let gray = resized.convertToGrayscale(),
            let bitmap = gray.convertTo1BitBitmap()
        else {
            return nil
        }
        return bitmap
    }


}
