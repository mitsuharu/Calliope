//
//  Print.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/04.
//

import Foundation

enum Print {
    
    /**
     製造会社
     */
    enum Manufacturer {
        case epson
        case sunmi
    }
    
    /**
     印刷命令
     */
    enum Job {
        
        case initialize
        case text(text: String, size: TextSize? = nil, style: TextStyle? = nil)
        case textSize(size: TextSize)
        case textStyle(style: TextStyle)
        case feed(count: Int)
        case qrCode(text: String)
        case rawCommond(data: Data)
        case image(imageURL: URL, imageWidth: ImageWidth = .standard)
        
        static func makeJobImage(
            image: UIImage,
            imageWidth: ImageWidth = .standard,
            filename: String = UUID().uuidString) -> Job?
        {
            let temp = image.resized(width: CGFloat(imageWidth.rawValue))
            guard let fileURL = Job.saveImageToSandbox(image: temp, filename: filename) else {
                return nil
            }
            return .image(imageURL: fileURL, imageWidth: imageWidth)
        }
        
        func image() -> UIImage? {
            switch self {
            case .image(let imageURL, _):
                return UIImage(contentsOfFile: imageURL.path)
            default:
                return nil
            }
        }

        func delete()  {
            switch self {
            case .image(let imageURL, _):
                try? FileManager.default.removeItem(at: imageURL)
            default:
                break
            }
        }
        
        private static func saveImageToSandbox(image: UIImage, filename: String) -> URL? {
            guard let data = image.pngData() else {
                return nil
            }
            
            do {
                let fileManager = FileManager.default
                let document = try fileManager.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                let dir = document.appendingPathComponent("print-job-image", isDirectory: true)
                
                // カスタムディレクトリが存在しない場合は作成
                if !fileManager.fileExists(atPath: dir.path) {
                    try fileManager.createDirectory(
                        at: dir,
                        withIntermediateDirectories: true,
                        attributes: nil)
                }
                
                let fileURL = dir.appendingPathComponent("\(filename).jpg")
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("Failed to write image data to file: \(error)")
                return nil
            }
        }
        
        /**
         テキストスタイル
         */
        enum TextStyle {
            case normal
            case bold
        }
        
        /**
         テキストサイズ
         */
        enum TextSize {
            case normal

            /**
             width と height はともに 1 ~ 8 まで設定できます
             */
            case scale(width: Int, height: Int)
        }
        
        enum ImageWidth: Int {
            case standard = 200
            case width58 = 384
            case width80 = 640
        }
    }
}
