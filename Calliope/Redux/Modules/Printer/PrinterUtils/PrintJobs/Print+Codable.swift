//
//  Print+Codable.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/30.
//

import Foundation

extension Print.Job.TextStyle: Codable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "normal":
            self = .normal
        case "bold":
            self = .bold
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid size value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .normal:
            try container.encode("normal")
        case .bold:
            try container.encode("bold")
        }
    }
}

extension Print.Job.TextSize: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
    }
    
    private enum TextSizeType: String, Codable {
        case normal
        case scale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TextSizeType.self, forKey: .type)
        
        switch type {
        case .normal:
            self = .normal
        case .scale:
            let width = try container.decode(Int.self, forKey: .width)
            let height = try container.decode(Int.self, forKey: .height)
            self = .scale(width: width, height: height)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .normal:
            try container.encode(TextSizeType.normal, forKey: .type)
        case .scale(let width, let height):
            try container.encode(TextSizeType.scale, forKey: .type)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        }
    }
}

extension Print.Job.ImageWidth: Codable {
    
}

extension Print.Job: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case size
        case style
        case count
        case data
        case image
        case imageWidth
    }
    
    private enum JobType: String, Codable {
        case initialize
        case text
        case textSize
        case textStyle
        case feed
        case qrCode
        case rawCommond
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(JobType.self, forKey: .type)
        
        switch type {
        case .initialize:
            self = .initialize
        case .text:
            let text = try container.decode(String.self, forKey: .text)
            let size = try container.decodeIfPresent(TextSize.self, forKey: .size)
            let style = try container.decodeIfPresent(TextStyle.self, forKey: .style)
            self = .text(text: text, size: size, style: style)
        case .textSize:
            let size = try container.decode(TextSize.self, forKey: .size)
            self = .textSize(size: size)
        case .textStyle:
            let style = try container.decode(TextStyle.self, forKey: .style)
            self = .textStyle(style: style)
        case .feed:
            let count = try container.decode(Int.self, forKey: .count)
            self = .feed(count: count)
        case .qrCode:
            let text = try container.decode(String.self, forKey: .text)
            self = .qrCode(text: text)
        case .rawCommond:
            let data = try container.decode(Data.self, forKey: .data)
            self = .rawCommond(data: data)
        case .image:
            let imageData = try container.decode(Data.self, forKey: .image)
            guard let image = UIImage(data: imageData) else {
                throw DecodingError.dataCorruptedError(forKey: .image, in: container, debugDescription: "Invalid image data")
            }
            let imageWidth = try container.decode(ImageWidth.self, forKey: .imageWidth)
            self = .image(image: image, imageWidth: imageWidth)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .initialize:
            try container.encode(JobType.initialize, forKey: .type)
        case .text(let text, let size, let style):
            try container.encode(JobType.text, forKey: .type)
            try container.encode(text, forKey: .text)
            try container.encodeIfPresent(size, forKey: .size)
            try container.encodeIfPresent(style, forKey: .style)
        case .textSize(let size):
            try container.encode(JobType.textSize, forKey: .type)
            try container.encode(size, forKey: .size)
        case .textStyle(let style):
            try container.encode(JobType.textStyle, forKey: .type)
            try container.encode(style, forKey: .style)
        case .feed(let count):
            try container.encode(JobType.feed, forKey: .type)
            try container.encode(count, forKey: .count)
        case .qrCode(let text):
            try container.encode(JobType.qrCode, forKey: .type)
            try container.encode(text, forKey: .text)
        case .rawCommond(let data):
            try container.encode(JobType.rawCommond, forKey: .type)
            try container.encode(data, forKey: .data)
        case .image(let image, let imageWidth):
            try container.encode(JobType.image, forKey: .type)
            guard let imageData = image.pngData() else {
                throw EncodingError.invalidValue(image, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid image data"))
            }
            try container.encode(imageData, forKey: .image)
            try container.encode(imageWidth, forKey: .imageWidth)
        }
    }
}
