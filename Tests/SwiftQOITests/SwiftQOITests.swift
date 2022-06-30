import XCTest
import UIKit
@testable import SwiftQOI

final class SwiftQOITests: XCTestCase {
    
    func testEncode() throws {
        let referenceData = getData(name: "reference", ext: "qoi")!
        let image = getImage(named: "reference")!
        let encoder = SwiftQOI()
        let imageComponents = image.pixelData()!
        let sut = encoder.encode(imageComponents: imageComponents)
        
        XCTAssertEqual(sut[14..<sut.count], referenceData[14..<referenceData.count])
    }
    
    func testDecode() throws {
        let referenceImage = getImage(named: "reference")!
        let referencePixels = referenceImage.pixelData()!.pixels
        let qoiData = getData(name: "reference", ext: "qoi")!
        
        let encoder = SwiftQOI()
        let sut = encoder.decode(data: qoiData)!.pixelsData
        
        XCTAssertEqual([UInt8](sut), referencePixels)
    }
    
    func testEncodeQOI() throws {
        let uiImage: UIImage = getImage(named: "reference")!
        let qoiData: Data = getQOIData(name: "reference")!
        
        let sut = uiImage.qoiData()
        XCTAssertEqual(sut?.count, qoiData.count)
    }
    
    func testDecodeQOI() throws {
        let qoiData: Data = getQOIData(name: "reference")!
        
        let sut = UIImage(qoi: qoiData)
        XCTAssertNotNil(sut)
    }
    
    func testEncode2() throws {
        let referenceData = getData(name: "reference2", ext: "qoi")!
        let image = getImage(named: "reference2")!
        let encoder = SwiftQOI()
        let imageComponents = image.pixelData()!
        let sut = encoder.encode(imageComponents: imageComponents)
        
        // FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("test.qoi")
//        try sut.write(to: url)
        
        XCTAssertEqual(sut[14..<sut.count], referenceData[14..<referenceData.count])
    }
    
    func testEncondeDecode2() throws {
        let image = getImage(named: "reference2")!
        
        let encoder = SwiftQOI()
        let imageComponents = image.pixelData()!
        
        let encoded = encoder.encode(imageComponents: imageComponents)
        let sut = UIImage(qoi: encoded)
        
        XCTAssertNotNil(sut)
    }
 
    func testDecode2() throws {
        let referenceImage = getImage(named: "reference2")!
        let referencePixels = referenceImage.pixelData()!.pixels
        let qoiData = getData(name: "reference2", ext: "qoi")!
        
        let encoder = SwiftQOI()
        let sut = encoder.decode(data: qoiData)!.pixelsData
        
        XCTAssertEqual(sut.count, referencePixels.count)
    }
    
    func testEncodeQOI2() throws {
        let uiImage: UIImage = getImage(named: "reference2")!
        let qoiData: Data = getQOIData(name: "reference2")!
        
        let sut = uiImage.qoiData()
        XCTAssertEqual(sut?.count, qoiData.count)
    }
    
    func testDecodeQOI2() throws {
        let qoiData: Data = getQOIData(name: "reference2")!
        
        let sut = UIImage(qoi: qoiData)
        XCTAssertNotNil(sut)
    }
    
//    func testCodeDecodeQOI() throws {
//        let image = getImage(named: "reference", ext: "png")!
//        let imageComponents = image.pixelData()!
//
//        let encoder = SwiftQOI()
//        let qoi = encoder.encode(imageComponents: imageComponents)
//        let sut = encoder.decode(data: qoi)!
//
//        XCTAssertEqual(sut.pixelsData, Data(imageComponents.pixels))
//    }
    
    func testQOIEncodePerformance() throws {
        let image = getImage(named: "reference2", ext: "png")!
        
        self.measure {
            for _ in [0..<10000] {
                let _ = image.qoiData
            }
        }
    }
    
    func testPNGEncodePerformance() throws {
        let image = getImage(named: "reference2", ext: "png")
        self.measure {
            for _ in [0..<10000] {
                let _ = image?.pngData()
            }
        }
    }
    
    func testQOIDecodePerformance() throws {
        let data = getData(name: "reference2", ext: "qoi")!
        let encoder = SwiftQOI()
        self.measure {
            for _ in [0..<10000] {
                let _ = encoder.decode(data: data)
            }
        }
    }
    
    func testPNGDecodePerformance() throws {
        let image = getImage(named: "reference2", ext: "png")!
        let data = image.pngData()!
        self.measure {
            for _ in [0..<10000] {
                let _ = UIImage(data: data)
            }
        }
    }
    
    func testWrite8Perfomance() throws {
        var buffer = [UInt8](repeating: 0, count: 1_000_000_000)
        var offset = 0
        self.measure {
            Utils.write8(value: 0xFF, offset: &offset, in: &buffer)
        }
    }
    
    func testWrite32Perfomance() throws {
        var buffer = [UInt8](repeating: 0, count: 1_000_000_000)
        var offset = 0
        self.measure {
            Utils.write32(value: 0xF0FF0F00, offset: &offset, in: &buffer)
        }
    }
    
    func getImage(named name: String, ext: String = "png") -> UIImage? {
        if let imgPath = Bundle.module.url(forResource: name, withExtension: ext) {
            return UIImage(contentsOfFile: imgPath.path)
        }
        return nil
    }
    
    func getData(name: String, ext: String) -> Data? {
        if let path = Bundle.module.url(forResource: name, withExtension: ext) {
            return try? Data(contentsOf: path)
        }
        return nil
    }
    
    func getQOIData(name: String) -> Data? {
        getData(name: name, ext: "qoi")
    }
}
