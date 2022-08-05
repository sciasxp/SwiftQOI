//
//  Pixel.swift
//  
//
//  Created by Luciano Nunes on 30/06/22.
//

import Foundation

struct Pixel: Equatable {
    let r, g, b, a: UInt8
    
    init(rgba: [UInt8]? = nil) {
        guard let rgba = rgba else {
            r = 0; g = 0; b = 0; a = 255
            return
        }
        
        r = rgba[0]
        g = rgba[1]
        b = rgba[2]
        
        if rgba.count > 3 { a = rgba[3] }
        else { a = 255 }
    }
    
    init(bgra: [UInt8]? = nil) {
        guard let bgra = bgra else {
            r = 0; g = 0; b = 0; a = 255
            return
        }
        
        r = bgra[2]
        g = bgra[1]
        b = bgra[0]
        
        if bgra.count > 3 { a = bgra[3] }
        else { a = 255 }
    }
    
    var description: String {
        String(format: "0x%02x", r) + String(format: "%02x", g) + String(format: "%02x", b) + String(format: "%02x", a)
    }
    
    var hash: Int {
        return (Int(r) * 3 + Int(g) * 5 + Int(b) * 7 + Int(a) * 11) % 64
    }
    
    static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        return (
            lhs.r == rhs.r &&
            lhs.g == rhs.g &&
            lhs.b == rhs.b &&
            lhs.a == rhs.a
        )
    }
    
    static func - (lhs: Pixel, rhs: Pixel) -> Pixel {
        let r: UInt8 = lhs.r &- rhs.r
        let g: UInt8 = lhs.g &- rhs.g
        let b: UInt8 = lhs.b &- rhs.b
        let a: UInt8 = lhs.a &- rhs.a
        
        return Pixel(rgba: [r, g, b, a])
    }
}
