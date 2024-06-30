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
        case image(image: UIImage, imageWidth: ImageWidth = .standard)
        
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


