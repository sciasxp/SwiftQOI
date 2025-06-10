//
//  Constants.swift
//  
//
//  Created by Luciano Nunes on 30/06/22.
//

import Foundation

struct Constants {
    static let QOI_HEADER_SIZE = 14
    static let QOI_END_MARKER: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 1]
    static var QOI_END_MARKER_SIZE: Int { QOI_END_MARKER.count }
    
    static let QOI_OP_RUN: UInt8 = 0xc0 // 11000000 bit
    static let QOI_OP_INDEX: UInt8 = 0x00
    static let QOI_OP_DIFF: UInt8 = 0x40 // 01000000 bit
    static let QOI_OP_LUMA: UInt8 = 0x80 // 10000000 bit
    
    static let QOI_OP_RGB: UInt8 = 0xfe // 11111110 bit
    static let QOI_OP_RGBA: UInt8 = 0xff // 11111111 bit
    
    static let MAX_REPEATING_PIXEL = 62
    static let RUNNING_ARRAY_SIZE = 64
    
    static let MAGIC: [UInt8] = [113, 111, 105, 102] // "qoif"
    
    // QOI specification limits
    static let MAX_PIXEL_COUNT: Int = 400_000_000
}
