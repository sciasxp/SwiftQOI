import Foundation
import CoreGraphics

public struct SwiftQOI {
    
    public typealias Components = (width: Int, height: Int, colorSpace: CGColorSpace, channels: Int, bytesPerRow: Int, bitmapInfo: UInt32, pixels: [UInt8])
    
    public init() {}
    
    public func isQOI(data: Data) -> Bool {
        let compressed: [UInt8] = [UInt8](data)
        let magic = Array(compressed[0..<4])
        return magic == Constants.MAGIC
    }
    
    public func encode(imageComponents: Components) -> Data {
        // Input validation
        guard imageComponents.width > 0 && imageComponents.height > 0 else {
            return Data()
        }
        guard imageComponents.width * imageComponents.height <= Constants.MAX_PIXEL_COUNT else {
            return Data() // Prevent overflow per QOI spec
        }
        guard imageComponents.channels == 3 || imageComponents.channels == 4 else {
            return Data()
        }
        guard !imageComponents.pixels.isEmpty else {
            return Data()
        }
        
        let channels = imageComponents.channels
        let pixels = imageComponents.pixels
        
        // Validate pixel data size matches dimensions
        let expectedPixelCount = imageComponents.width * imageComponents.height * channels
        guard pixels.count >= expectedPixelCount else {
            return Data()
        }
        
        // More precise buffer size calculation
        // Worst case: every pixel needs RGBA chunk (5 bytes each) + header + end marker
        let pixelCount = imageComponents.width * imageComponents.height
        let MAX_BUFFER_SIZE = (pixelCount * 5) + Constants.QOI_HEADER_SIZE + Constants.QOI_END_MARKER_SIZE
        
        let LAST_PIXEL = pixels.count
        
        var buffer: [UInt8] = [UInt8](repeating: 0, count: MAX_BUFFER_SIZE)
        var index: Int = 0
        
        let header = QOIHeader (
            magic: Constants.MAGIC,
            width: UInt32(imageComponents.width),
            height: UInt32(imageComponents.height),
            channels: UInt8(channels),
            colorspace: imageComponents.colorSpace.name == CGColorSpace.sRGB ? 0 : 1
        )
        Utils.writeHeader(header, offset: &index, buffer: &buffer)
        
        var runningArray: [Pixel] = [Pixel](repeating: Pixel(rgba: nil), count: Constants.RUNNING_ARRAY_SIZE)
        var previousPixel: Pixel = Pixel(rgba: nil)
        
        var run: Int = 0
        
        for pixelsIndex in stride(from: 0, to: LAST_PIXEL, by: channels) {
            let rgba: [UInt8] = Array(pixels[pixelsIndex..<(pixelsIndex + channels)])
            let pixel = imageComponents.bitmapInfo == 8194 ? Pixel(bgra: rgba) : Pixel(rgba: rgba)
            
            if previousPixel == pixel {
                run += 1
                if run == Constants.MAX_REPEATING_PIXEL || pixelsIndex == LAST_PIXEL - channels {
                    Utils.write8(value: Constants.QOI_OP_RUN | UInt8(run - 1), offset: &index, in: &buffer)
                    run = 0
                }
            } else {
                if run > 0 {
                    Utils.write8(value: Constants.QOI_OP_RUN | UInt8(run - 1), offset: &index, in: &buffer)
                    run = 0
                }
                
                let hash = pixel.hash
                if runningArray[hash] == pixel {
                    Utils.write8(value: Constants.QOI_OP_INDEX | UInt8(hash), offset: &index, in: &buffer)
                    
                } else {
                    runningArray[hash] = pixel
                    
                    let diff = pixel - previousPixel
                    if diff.a == 0 {
                        if Utils.isDIFFCondition(for: pixel, previous: previousPixel) {
                            Utils.writeDIFF(value: diff, offset: &index, buffer: &buffer)
                            
                        } else if Utils.isLUMACondition(for: pixel, previous: previousPixel) {
                            Utils.writeLUMA(value: diff, offset: &index, buffer: &buffer)
                            
                        } else {
                            Utils.writeRGB(value: pixel, offset: &index, in: &buffer)
                        }
                    } else {
                        Utils.writeRGBA(value: pixel, offset: &index, in: &buffer)
                    }
                }
            }
            
            previousPixel = pixel
        }
        
        Constants.QOI_END_MARKER.forEach { byte in
            Utils.write8(value: byte, offset: &index, in: &buffer)
        }
        
        return Data(buffer[0..<index])
    }
    
    public func decode(data: Data) -> (pixelsData: Data, header: QOIHeader)? {
        // Input validation
        guard data.count >= Constants.QOI_HEADER_SIZE + Constants.QOI_END_MARKER_SIZE else {
            return nil
        }
        
        let compressed: [UInt8] = [UInt8](data)
        
        let header = QOIHeader (
            magic: Array(compressed[0..<4]),
            width: Utils.toUInt32(Array(compressed[4..<8])),
            height: Utils.toUInt32(Array(compressed[8..<12])),
            channels: compressed[12],
            colorspace: compressed[13]
        )
        
        guard header.magic == Constants.MAGIC else { return nil }
        guard header.width > 0 && header.height > 0 else { return nil }
        guard header.channels == 3 || header.channels == 4 else { return nil }
        guard Int(header.width) * Int(header.height) <= Constants.MAX_PIXEL_COUNT else { return nil }
        
        let MAX_BUFFER_SIZE = Int(header.width) * Int(header.height) * 4
        
        var runningArray: [Pixel] = [Pixel](repeating: Pixel(rgba: nil), count: Constants.RUNNING_ARRAY_SIZE)
        var previousPixel: Pixel = Pixel(rgba: nil)
        
        var buffer: [UInt8] = [UInt8](repeating: 0, count: MAX_BUFFER_SIZE)
        var index: Int = 0
        var chunk: Int = Constants.QOI_HEADER_SIZE
        
        repeat {
            // Bounds check before accessing
            guard chunk < compressed.count else { return nil }
            
            if compressed[chunk] == Constants.QOI_OP_RGB {
                guard chunk + 3 < compressed.count else { return nil }
                previousPixel = Pixel(rgba: [compressed[chunk + 1], compressed[chunk + 2], compressed[chunk + 3]])
                
                Utils.write8(value: compressed[chunk + 1], offset: &index, in: &buffer)
                Utils.write8(value: compressed[chunk + 2], offset: &index, in: &buffer)
                Utils.write8(value: compressed[chunk + 3], offset: &index, in: &buffer)
                if header.channels == 4 {
                    Utils.write8(value: previousPixel.a, offset: &index, in: &buffer)
                } else {
                    Utils.write8(value: 255, offset: &index, in: &buffer)
                }
                chunk += 4
                
                runningArray[previousPixel.hash] = previousPixel
                
                continue
            }
            
            if compressed[chunk] == Constants.QOI_OP_RGBA {
                guard chunk + 4 < compressed.count else { return nil }
                previousPixel = Pixel(rgba: [compressed[chunk + 1], compressed[chunk + 2], compressed[chunk + 3], compressed[chunk + 4]])
                
                Utils.write8(value: compressed[chunk + 1], offset: &index, in: &buffer)
                Utils.write8(value: compressed[chunk + 2], offset: &index, in: &buffer)
                Utils.write8(value: compressed[chunk + 3], offset: &index, in: &buffer)
                Utils.write8(value: compressed[chunk + 4], offset: &index, in: &buffer)
                chunk += 5
                
                runningArray[previousPixel.hash] = previousPixel
                
                continue
            }
            
            if compressed[chunk] & 0xC0 == Constants.QOI_OP_INDEX {
                let hash: Int = Int(compressed[chunk] & 0x3F)
                let pixel = runningArray[hash]
                
                Utils.write8(value: pixel.r, offset: &index, in: &buffer)
                Utils.write8(value: pixel.g, offset: &index, in: &buffer)
                Utils.write8(value: pixel.b, offset: &index, in: &buffer)
                if header.channels == 4 {
                    Utils.write8(value: pixel.a, offset: &index, in: &buffer)
                } else {
                    Utils.write8(value: 255, offset: &index, in: &buffer)
                }
                
                previousPixel = pixel
                runningArray[previousPixel.hash] = previousPixel
                
                chunk += 1
                continue
            }
            
            if compressed[chunk] & 0xC0 == Constants.QOI_OP_DIFF {
                let dr = ((compressed[chunk] & 0x30) >> 4) &- 2
                let dg = ((compressed[chunk] & 0x0C) >> 2) &- 2
                let db = (compressed[chunk] & 0x03) &- 2
                
                let r = previousPixel.r &+ dr
                let g = previousPixel.g &+ dg
                let b = previousPixel.b &+ db
                
                let pixel = Pixel(rgba: [r, g, b, previousPixel.a])
                
                Utils.write8(value: pixel.r, offset: &index, in: &buffer)
                Utils.write8(value: pixel.g, offset: &index, in: &buffer)
                Utils.write8(value: pixel.b, offset: &index, in: &buffer)
                if header.channels == 4 {
                    Utils.write8(value: pixel.a, offset: &index, in: &buffer)
                } else {
                    Utils.write8(value: 255, offset: &index, in: &buffer)
                }
                
                previousPixel = pixel
                runningArray[previousPixel.hash] = previousPixel
                
                chunk += 1
                continue
            }
            
            if compressed[chunk] & 0xC0 == Constants.QOI_OP_LUMA {
                guard chunk + 1 < compressed.count else { return nil }
                let diffG = (compressed[chunk] & 0x3F) &- 32
                let dr_dg = ((compressed[chunk + 1] & 0xF0) >> 4) &- 8
                let db_dg = (compressed[chunk + 1] & 0x0F) &- 8
                
                let r = previousPixel.r &+ dr_dg &+ diffG
                let b = previousPixel.b &+ db_dg &+ diffG
                let g = previousPixel.g &+ diffG
                
                let pixel = Pixel(rgba: [r, g, b, previousPixel.a])
                
                Utils.write8(value: pixel.r, offset: &index, in: &buffer)
                Utils.write8(value: pixel.g, offset: &index, in: &buffer)
                Utils.write8(value: pixel.b, offset: &index, in: &buffer)
                if header.channels == 4 {
                    Utils.write8(value: pixel.a, offset: &index, in: &buffer)
                } else {
                    Utils.write8(value: 255, offset: &index, in: &buffer)
                }
                
                previousPixel = pixel
                runningArray[previousPixel.hash] = previousPixel
                
                chunk += 2
                continue
            }
            
            if compressed[chunk] & 0xC0 == Constants.QOI_OP_RUN {
                var run = compressed[chunk] & 0x3F + 1
                
                repeat {
                    Utils.write8(value: previousPixel.r, offset: &index, in: &buffer)
                    Utils.write8(value: previousPixel.g, offset: &index, in: &buffer)
                    Utils.write8(value: previousPixel.b, offset: &index, in: &buffer)
                    
                    if header.channels == 4 {
                        Utils.write8(value: previousPixel.a, offset: &index, in: &buffer)
                    } else {
                        Utils.write8(value: 255, offset: &index, in: &buffer)
                    }
                    
                    run -= 1
                    
                } while(run > 0)
                
                chunk += 1
                continue
            }
            
        } while(chunk < compressed.count - Constants.QOI_END_MARKER_SIZE)
        
        return (pixelsData: Data(buffer[0..<index]), header: header)
    }
}
