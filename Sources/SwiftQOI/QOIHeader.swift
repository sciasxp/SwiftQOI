//
//  QOIHeader.swift
//  
//
//  Created by Luciano Nunes on 30/06/22.
//

import Foundation

struct QOIHeader {
    let magic: [UInt8]      // magic bytes "qoif"
    let width: UInt32       // image width in pixels (BE)
    let height: UInt32      // image height in pixels (BE)
    let channels: UInt8     // 3 = RGB, 4 = RGBA
    let colorspace: UInt8   // 0 = sRGB with linear alpha
    // 1 = all channels linear
}
