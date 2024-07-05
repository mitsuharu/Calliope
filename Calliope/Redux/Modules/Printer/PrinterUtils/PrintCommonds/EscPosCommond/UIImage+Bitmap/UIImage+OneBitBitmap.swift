//
//  UIImage+OneBitBitmap.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/02.
//

import Foundation

extension UIImage {
        
    struct OneBitBitmap {
        let data: [UInt8]
        let width: Int
        let height: Int
    }
    
    func resized(width: CGFloat) -> UIImage {
        let height: CGFloat = ((self.size.height / self.size.width) * CGFloat(width)).rounded()
        let size = CGSize(width: width, height: height)
        return self.resized(size: size)
    }
    
    func resized(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image {
            _ in draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func grayscaleImage() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let context = CIContext(options: nil)
        let ciImage = CIImage(cgImage: cgImage)
        let grayscale = ciImage.applyingFilter("CIPhotoEffectMono", parameters: [:])
        
        guard
            let cgImageResult = context.createCGImage(grayscale, from: grayscale.extent)
        else {
            return nil
        }
        return UIImage(cgImage: cgImageResult)
    }
    
    func ditherImage() -> UIImage? {
        guard
            let grayscaleImage = self.grayscaleImage(),
            let cgImage = grayscaleImage.cgImage
        else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
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
        
        // Floyd-Steinberg dithering
        for y in 0..<height {
            for x in 0..<width {
                let i = y * width + x
                let oldPixel = data[i]
                let newPixel: UInt8 = oldPixel < 128 ? 0 : 255
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
        
        guard let outputCgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: outputCgImage)
    }
}
    
