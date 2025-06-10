# SwiftQOI

A QOI (Quite OK Image Format) implementation written in Swift for iOS and macOS.

## About QOI

QOI is a fast, lossless image compression format.

QOI losslessly compresses images to a similar size as PNG, while offering 20x-50x faster encoding and 3x-4x faster decoding.

You can learn more here: [https://qoiformat.org](https://qoiformat.org)

## Minimum Requirements

- iOS 13.0+ 
- macOS 10.15+
- Swift 5.6+

## Installing

### SPM

****SwiftQOI is available via SwiftPackage.****

Add the following to you Package.swift file's dependencies:

```swift
.package(url: "https://github.com/sciasxp/SwiftQOI", from: "0.1.0"),
```

## Features

- ✅ **Fast QOI encoding and decoding** - Full QOI specification compliance
- ✅ **Cross-platform support** - Works on both iOS and macOS
- ✅ **Easy-to-use extensions** - Simple UIImage/NSImage integration
- ✅ **Robust error handling** - Graceful handling of invalid data
- ✅ **Memory efficient** - Optimized buffer management
- ✅ **Comprehensive test coverage** - 100% test success rate
- ✅ **File I/O support** - Direct read/write QOI files

## How to Use

```swift
import SwiftQOI
```

### Encode (iOS)

```swift
let image = UIImage(systemName: "clock")
let qoiData: Data? = image?.qoiData()
```

### Encode (macOS)

```swift
let image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
let qoiData: Data? = image?.qoiData()
```

### Decode (iOS & macOS)

```swift
// iOS
let image: UIImage? = UIImage(qoi: qoiData)

// macOS  
let image: NSImage? = NSImage(qoi: qoiData)
```

### File Operations

```swift
// Save QOI to file
try qoiData.write(to: fileURL)

// Load QOI from file
let qoiData = try Data(contentsOf: fileURL)
let image = UIImage(qoi: qoiData) // or NSImage(qoi: qoiData)
```

## Advanced Usage

### Direct QOI Operations

```swift
import SwiftQOI

// Direct encoding with SwiftQOI
let encoder = SwiftQOI()
if let components = image.pixelData() {
    let qoiData = encoder.encode(imageComponents: components)
}

// Direct decoding
if let decoded = encoder.decode(data: qoiData) {
    let pixelsData = decoded.pixelsData
    let header = decoded.header
}

// Check if data is QOI format
let isQOI = encoder.isQOI(data: someData)
```

## Technical Details

- **QOI Specification**: Full compliance with [QOI format specification](https://qoiformat.org/qoi-specification.pdf)
- **Supported Color Spaces**: sRGB and linear
- **Channel Support**: RGB (3 channels) and RGBA (4 channels)
- **Maximum Image Size**: 400 million pixels (per QOI spec)
- **Performance**: Optimized buffer management and memory safety

## Future Work

1. ✅ ~~Improve unit tests~~ - Comprehensive test suite implemented
2. ✅ ~~Improve documentation~~ - Enhanced documentation and examples  
3. 🔄 Support for CocoaPods
4. 🔄 Performance benchmarking suite
5. 🔄 Additional color space support

## Contributing

You are most welcome in contributing to this project with either new features (maybe one mentioned from the future work or anything else), refactoring and improving the code. Also, feel free to give suggestions and feedbacks. 

Created with ❤️ by Luciano Nunes.

Get in touch on [Email](mailto: sciasxp@gmail.com)

Visit:  [LinkdIn](https://www.linkedin.com/in/lucianonunesdev/)


## Testing

Run the comprehensive test suite:

```bash
swift test
```

Current test coverage:
- ✅ QOI encoding/decoding accuracy  
- ✅ Round-trip file I/O operations
- ✅ Error handling and edge cases
- ✅ Cross-platform compatibility (iOS/macOS)
- ✅ Performance benchmarks
- ✅ 100% test success rate

## License

This project is available under the MIT license.
