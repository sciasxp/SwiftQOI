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
    
    public func pixelData() -> (width: Int, height: Int, colorSpace: CGColorSpace, channels: Int, bytesPerRow: Int, bitmapInfo: UInt32, pixels: [UInt8])? {
        guard let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace else { return nil }
        
//        let contextChannels: CGFloat = (cgImage.alphaInfo == .noneSkipLast || cgImage.alphaInfo == .noneSkipFirst || cgImage.alphaInfo == .none) ? 3 : 4
        let channels: CGFloat = cgImage.alphaInfo == .none ? 3 : 4
        let bytesPerRow = cgImage.alphaInfo == .none ? Int(3 * size.width) : Int(4 * size.width)
        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
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
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return (
            width: Int(self.size.width),
            height: Int(self.size.height),
            colorSpace: colorSpace,
            channels: Int(channels),
            bytesPerRow: bytesPerRow,
            bitmapInfo: cgImage.bitmapInfo.rawValue,
            pixels: pixelData
        )
    }
    
    func resizedImageKeepingAspect(for targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
//    func resizedImageKeepingAspect(for size: CGSize) -> UIImage? {
//        guard size != .zero else {
//            return self
//        }
//
//        let options: [CFString: Any] = [
//            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceShouldCacheImmediately: true,
//            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
//        ]
//
//        guard let data = self.pngData(),
//              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
//              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
//            return nil
//        }
//
//        return UIImage(cgImage: image)
//    }
}
