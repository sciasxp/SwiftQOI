//
//  Utils.swift
//  
//
//  Created by Luciano Nunes on 30/06/22.
//

import Foundation

struct Utils {
    
    static func writeHeader(_ header: QOIHeader, offset: inout Int, buffer: inout [UInt8]) {
        header.magic.forEach { qoif in
            write8(value: qoif, offset: &offset, in: &buffer)
        }
        
        write32(value: header.width, offset: &offset, in: &buffer)
        write32(value: header.height, offset: &offset, in: &buffer)
        write8(value: header.channels, offset: &offset, in: &buffer)
        write8(value: header.colorspace, offset: &offset, in: &buffer)
    }
    
    static func write32(value: UInt32, offset: inout Int, in buffer: inout [UInt8]) {
        guard offset + 3 < buffer.count else { return }
        buffer[offset] = UInt8((value & 0xFF000000) >> 24)
        buffer[offset + 1] = UInt8((value & 0x00FF0000) >> 16)
        buffer[offset + 2] = UInt8((value & 0x0000FF00) >> 8)
        buffer[offset + 3] = UInt8(value & 0x000000FF)
        offset += 4
    }
    
    static func write8(value: UInt8, offset: inout Int, in buffer: inout [UInt8]) {
        guard offset < buffer.count else { return }
        buffer[offset] = value
        offset += 1
    }
    
    static func isDIFFCondition(for pixel: Pixel, previous: Pixel) -> Bool {
        let diffR = Int(pixel.r) - Int(previous.r)
        let diffG = Int(pixel.g) - Int(previous.g)
        let diffB = Int(pixel.b) - Int(previous.b)
        
        return (diffR >= -2 && diffR <= 1) &&
        (diffG >= -2 && diffG <= 1) &&
        (diffB >= -2 && diffB <= 1)
    }
    
    static func writeDIFF(value: Pixel, offset: inout Int, buffer: inout [UInt8]) {
        buffer[offset] = Constants.QOI_OP_DIFF | (value.r &+ 2) << 4 | (value.g &+ 2) << 2 | (value.b &+ 2)
        offset += 1
    }
    
    static func isLUMACondition(for pixel: Pixel, previous: Pixel) -> Bool {
        let diffR = pixel.r &- previous.r
        let diffG = pixel.g &- previous.g
        let diffB = pixel.b &- previous.b
        
        let drDg = diffR &- diffG
        let dbDg = diffB &- diffG
        
        return (
            (Int8(bitPattern: diffG) >= -32 && Int8(bitPattern: diffG) <= 31) &&
            (Int8(bitPattern: drDg) >= -8 && Int8(bitPattern: drDg) <= 7) &&
            (Int8(bitPattern: dbDg) >= -8 && Int8(bitPattern: dbDg) <= 7)
        )
    }
    
    static func writeLUMA(value: Pixel, offset: inout Int, buffer: inout [UInt8]) {
        let drDg = value.r &- value.g
        let dbDg = value.b &- value.g
        
        let green = value.g &+ 32
        
        buffer[offset] = Constants.QOI_OP_LUMA | green
        offset += 1
        
        buffer[offset] = (drDg &+ 8) << 4 | (dbDg &+ 8)
        offset += 1
    }
    
    static func writeRGB(value: Pixel, offset: inout Int, in buffer: inout [UInt8]) {
        write8(value: Constants.QOI_OP_RGB, offset: &offset, in: &buffer)
        write8(value: value.r, offset: &offset, in: &buffer)
        write8(value: value.g, offset: &offset, in: &buffer)
        write8(value: value.b, offset: &offset, in: &buffer)
    }
    
    static func writeRGBA(value: Pixel, offset: inout Int, in buffer: inout [UInt8]) {
        write8(value: Constants.QOI_OP_RGBA, offset: &offset, in: &buffer)
        write8(value: value.r, offset: &offset, in: &buffer)
        write8(value: value.g, offset: &offset, in: &buffer)
        write8(value: value.b, offset: &offset, in: &buffer)
        write8(value: value.a, offset: &offset, in: &buffer)
    }
    
    static func toUInt32(_ bytes: [UInt8]) -> UInt32 {
        guard bytes.count == 4 else { return 0 }
        let long: UInt32 = UInt32(bytes[0]) << 24 | UInt32(bytes[1]) << 16 | UInt32(bytes[2]) << 8 | UInt32(bytes[3])
        return long
    }
}
