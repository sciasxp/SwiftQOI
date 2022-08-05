//
//  UIImage+Extension.swift
//  
//
//  Created by Luciano Nunes on 30/06/22.
//

import UIKit

extension UIImage {
    
    static func ==(lhs: UIImage, rhs: UIImage) -> Bool {
        lhs === rhs || lhs.pngData() == rhs.pngData()
    }
    
    public convenience init?(qoi: Data) {
        let encoder = SwiftQOI()
        guard let components = encoder.decode(data: qoi) else { return nil }
        
        let width = Int(components.header.width)
        let height = Int(components.header.height)
        let channels = Int(components.header.channels)
        let pixelsData = components.pixelsData
        let colorSpace = components.header.colorspace
        
        guard width > 0 && height > 0,
              pixelsData.count / 4 == width * height,
              let providerRef = CGDataProvider(data: pixelsData as CFData) else { return nil }
        
        guard let cgim = CGImage (
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace == 0 ? CGColorSpaceCreateDeviceRGB() : CGColorSpaceCreateDeviceGray(),
            bitmapInfo: channels == 4 ? CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue) : CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent)
        else { return nil }
        
        self.init(cgImage: cgim)
    }
    
    public func qoiData() -> Data? {
        guard let components = self.pixelData() else { return nil }
        let encoder = SwiftQOI()
        let data = encoder.encode(imageComponents: components)
        return data
    }
    
    public func pixelData() -> (width: Int, height: Int, colorSpace: CGColorSpace, channels: Int, bytesPerRow: Int, pixels: [UInt8])? {
        guard let cgImage = self.cgImage else { return nil }
        
//        let contextChannels: CGFloat = (cgImage.alphaInfo == .noneSkipLast || cgImage.alphaInfo == .noneSkipFirst || cgImage.alphaInfo == .none) ? 3 : 4
        let channels: CGFloat = cgImage.alphaInfo == .none ? 3 : 4
        let bytesPerRow = cgImage.alphaInfo == .none ? Int(3 * size.width) : Int(4 * size.width)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let size = self.size
        let dataSize = size.width * size.height * channels
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        guard let context = CGContext (
            data: &pixelData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: cgImage.alphaInfo.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return (
            width: Int(self.size.width),
            height: Int(self.size.height),
            colorSpace: colorSpace,
            channels: Int(channels),
            bytesPerRow: bytesPerRow,
            pixels: pixelData
        )
    }
}
