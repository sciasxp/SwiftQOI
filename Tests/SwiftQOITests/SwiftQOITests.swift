import XCTest
import UIKit
@testable import SwiftQOI

final class SwiftQOITests: XCTestCase {
    
    func testIsQOI() throws {
        let referenceData = getData(name: "reference", ext: "qoi")!
        let encoder = SwiftQOI()
        let sut = encoder.isQOI(data: referenceData)
        XCTAssertTrue(sut)
    }
    
    func testIsQOIFailed() throws {
        let referenceData = getData(name: "reference", ext: "png")!
        let encoder = SwiftQOI()
        let sut = encoder.isQOI(data: referenceData)
        XCTAssertFalse(sut)
    }
    
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
