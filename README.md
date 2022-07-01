# SwiftQOI

An QOI (Quite OK Image Format) implementation written in Swift to be used with iOS.

## About QOI

QOI is compression image format.

QOI is fast. It losslessy compresses images to a similar size of PNG, while offering 20x-50x faster encoding and 3x-4x faster decoding.

You can learn more here: [https://qoiformat.org]()

## Minimum Requirements

This framework will be usable by iOS 13 and above or MacOS 10.15 and above.

## Installing

### SPM

****SwiftQOI is available via SwiftPackage.****

Add the following to you Package.swift file's dependencies:

```swift
.package(url: "https://github.com/sciasxp/SwiftQOI", from: "0.1.0"),
```

## Features

- Encode and Decode image pixels representation data to/from QOI.
  
- Extension to UIImage for easy handling QOI on your projects.
  

## How to Use

```swift
import SwiftQOI
```

### Encode

```swift
let image = UIImage(systemName: "clock")
let qoiData: Data? = image.qoiData()
```

### Decode

```swift
let image: UIImage? = UIImage(qoi: qoiData)
```

## ## Future Work

1. Improve unit tests.
  
2. Improve documentation.
  
3. Support for cocoapods
  

## Contributing

You are most welcome in contributing to this project with either new features (maybe one mentioned from the future work or anything else), refactoring and improving the code. Also, feel free to give suggestions and feedbacks. 

Created with ❤️ by Luciano Nunes.

Get in touch on [Email](mailto: sciasxp@gmail.com)

Visit:  [LinkdIn](https://www.linkedin.com/in/lucianonunesdev/)
