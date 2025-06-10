//
//  PlatformImage.swift
//  
//
//  Created by SwiftQOI on 06/10/2025.
//

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

import CoreGraphics

extension PlatformImage {
    public convenience init?(qoi: Data) {
        let encoder = SwiftQOI()
        guard let components = encoder.decode(data: qoi) else { return nil }
        
        let width = Int(components.header.width)
        let height = Int(components.header.height)
        let channels = Int(components.header.channels)
        let pixelsData = components.pixelsData
        let colorSpace = components.header.colorspace
        
        guard width > 0 && height > 0,
              width * height <= Constants.MAX_PIXEL_COUNT,
              pixelsData.count == width * height * 4, // QOI decoder always outputs RGBA
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
        
        #if canImport(UIKit)
        self.init(cgImage: cgim)
        #elseif canImport(AppKit)
        self.init(cgImage: cgim, size: NSSize(width: width, height: height))
        #endif
    }
    
    public func qoiData() -> Data? {
        guard let components = self.pixelData() else { return nil }
        let encoder = SwiftQOI()
        let data = encoder.encode(imageComponents: components)
        return data
    }
    
    public func pixelData() -> (width: Int, height: Int, colorSpace: CGColorSpace, channels: Int, bytesPerRow: Int, bitmapInfo: UInt32, pixels: [UInt8])? {
        #if canImport(UIKit)
        guard let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace else { return nil }
        let size = self.size
        #elseif canImport(AppKit)
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let colorSpace = cgImage.colorSpace else { return nil }
        let size = self.size
        #endif
        
        let channels: CGFloat = cgImage.alphaInfo == .none ? 3 : 4
        let bytesPerRow = cgImage.alphaInfo == .none ? Int(3 * size.width) : Int(4 * size.width)
        
        let dataSize = size.width * size.height * channels
        guard dataSize <= Double(Constants.MAX_PIXEL_COUNT * 4) else { return nil } // Safety check
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
            width: Int(size.width),
            height: Int(size.height),
            colorSpace: colorSpace,
            channels: Int(channels),
            bytesPerRow: bytesPerRow,
            bitmapInfo: cgImage.bitmapInfo.rawValue,
            pixels: pixelData
        )
    }
}

#if canImport(UIKit)
extension UIImage {
    static func ==(lhs: UIImage, rhs: UIImage) -> Bool {
        lhs === rhs || lhs.pngData() == rhs.pngData()
    }
    
    func resizedImageKeepingAspect(for targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
#endif

#if canImport(AppKit)
extension NSImage {
    static func ==(lhs: NSImage, rhs: NSImage) -> Bool {
        guard let lhsData = lhs.tiffRepresentation,
              let rhsData = rhs.tiffRepresentation else { return false }
        return lhsData == rhsData
    }
    
    public func pngData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .png, properties: [:])
    }
    
    func resizedImageKeepingAspect(for targetSize: NSSize) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        let size = self.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: NSSize
        if widthRatio > heightRatio {
            newSize = NSSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = NSSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(data: nil,
                                     width: Int(newSize.width),
                                     height: Int(newSize.height),
                                     bitsPerComponent: 8,
                                     bytesPerRow: 0,
                                     space: colorSpace,
                                     bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: newSize))
        
        guard let newCGImage = context.makeImage() else { return nil }
        return NSImage(cgImage: newCGImage, size: newSize)
    }
}
#endif