//
//  UIImage+Extension.swift
//  
//
//  Created by Luciano Nunes on 30/06/22.
//

import UIKit

extension UIImage {
    
    public convenience init?(qoi: Data) {
        let encoder = SwiftQOI()
        guard let components = encoder.decode(data: qoi) else { return nil }
        
        let width = Int(components.header.width)
        let height = Int(components.header.height)
        let channels = Int(components.header.channels)
        let pixelsData = components.pixelsData
        
        guard width > 0 && height > 0,
              pixelsData.count / channels == width * height,
              let providerRef = CGDataProvider(data: pixelsData as CFData) else { return nil }
        
        guard let cgim = CGImage (
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * channels,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
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
    
    public func pixelData() -> (width: Int, height: Int, colorSpace: CGColorSpace, channels: Int, pixels: [UInt8])? {
        guard let cgImage = self.cgImage else { return nil }
        
        let channels: CGFloat = 4//cgImage.alphaInfo == .none ? 3 : 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let size = self.size
        let dataSize = size.width * size.height * channels
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let context = CGContext (
            data: &pixelData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(channels * size.width),
            space: colorSpace,
            bitmapInfo: cgImage.alphaInfo.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return (
            width: Int(self.size.width),
            height: Int(self.size.height),
            colorSpace: colorSpace,
            channels: Int(channels),
            pixels: pixelData
        )
    }
}
