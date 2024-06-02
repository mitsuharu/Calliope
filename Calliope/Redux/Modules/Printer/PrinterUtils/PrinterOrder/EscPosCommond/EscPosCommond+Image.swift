//
//  EscPosCommond+Image.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/06.
//

import Foundation
import Bitmap
import CoreGraphics

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
            print("bitmap.size: \(bitmap.size)")
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
    
    func convertImageToBitmapData(targetSize: CGSize) -> Data? {
        
        // 画像サイズを変更
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgImage = resizedImage.cgImage else { return nil }
                
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let pixelData = context.data else { return nil }
        
        let data = Data(bytes: pixelData, count: height * bytesPerRow)
        return data
    }
    
    func convertImageToRaster(targetSize: CGSize) -> Data? {
        // 画像サイズを変更
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgImage = resizedImage.cgImage else { return nil }
        
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let pixelData = context.data else { return nil }
        
        let data = Data(bytes: pixelData, count: width * height)
        return data
    }
    

    func convertImageToMonochromeBitmap(targetSize: CGSize) -> Data? {
        // 画像サイズを変更
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgImage = resizedImage.cgImage else { return nil }
        
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let pixelData = context.data else { return nil }
        
        var monochromeData = Data()
        
        for y in 0..<height {
            for x in 0..<width {
                let pixel = pixelData.load(fromByteOffset: y * width + x, as: UInt8.self)
                let monochromePixel: UInt8 = pixel < 128 ? 0x00 : 0xFF
                monochromeData.append(monochromePixel)
            }
        }
        
        return monochromeData
    }


}



extension UIImage {
    
    private func resizeImage(cgImage: CGImage, size: CGSize) -> CGImage? {
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        context?.interpolationQuality = .high
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: Int(size.width), height: Int(size.height)))
        
        return context?.makeImage()
    }
    
    func to1BitBitmap(size: CGSize) -> Data? {
                
        guard let cgImage = self.cgImage else { return nil }

        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bytesPerRow = (width + 7) / 8
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        // Create a grayscale context with 1-bit per pixel
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            print("Failed to create CGContext")
            return nil
        }
                
        print("to1BitBitmap context")

        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

        // Resize the image to target dimensions
        guard let resizedCgImage = self.resizeImage(cgImage: cgImage, size: size) else {
            return nil
        }
        
        context.draw(resizedCgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var bitmapData = Data(count: height * bytesPerRow)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let byteIndex = y * bytesPerRow + x / 8
                let bitIndex = 7 - (x % 8)
                let grayValue = rawData[pixelIndex]
                
                if grayValue < 128 {
                    bitmapData[byteIndex] |= (1 << bitIndex)
                }
            }
        }
        
        return bitmapData
    }
}
