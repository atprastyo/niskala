// Run from the repository root:
// swift -module-cache-path /tmp/niskala-swift-cache tools/export_male_hero.swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct Atlas: Decodable {
    let action: String
    let source: String
    let columns: Int
    let rows: Int
    let frames: Int
    let directions: [String]
    let frameSize: Int?
    let drawScale: Double?
    let bodyCenterX: Double?
    let footBaselines: [Double]?
}
let manifest = try Data(contentsOf: URL(fileURLWithPath: "tools/male_hero-assets.json"))
let atlases = try JSONDecoder().decode([Atlas].self, from: manifest)
for atlas in atlases {
    let frameSize = atlas.frameSize ?? 256
    let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: atlas.source) as CFURL, nil)!
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
    let cellWidth = Double(image.width) / Double(atlas.columns)
    let cellHeight = Double(image.height) / Double(atlas.rows)
    precondition(atlas.columns * atlas.rows == atlas.frames * atlas.directions.count)
    for (directionIndex, direction) in atlas.directions.enumerated() {
        let context = CGContext(data: nil, width: frameSize * atlas.frames, height: frameSize,
            bitsPerComponent: 8, bytesPerRow: frameSize * atlas.frames * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.interpolationQuality = .high
        for frameIndex in 0..<atlas.frames {
            let index = directionIndex * atlas.frames + frameIndex
            let x = Double(index % atlas.columns) * cellWidth
            let y = Double(index / atlas.columns) * cellHeight
            let frame = image.cropping(to: CGRect(x: x.rounded(), y: y.rounded(),
                width: cellWidth.rounded(.down), height: cellHeight.rounded(.down)))!
            let destination: CGRect
            if let scale = atlas.drawScale {
                // Larger attack canvases retain the sword arc while matching the
                // movement hero's body scale and foot baseline at render time.
                let extent = Double(frameSize) * scale
                let baseline = atlas.footBaselines![directionIndex]
                destination = CGRect(
                    x: Double(frameIndex * frameSize) + Double(frameSize) / 2 - extent * atlas.bodyCenterX!,
                    y: 24 - extent * (1 - baseline), width: extent, height: extent)
            } else {
                destination = CGRect(x: frameIndex * frameSize + 4, y: 4,
                    width: frameSize - 8, height: frameSize - 8)
            }
            context.draw(frame, in: destination)
        }
        let suffix = direction == "right" ? "" : "_\(direction)"
        let output = "assets/images/player/male_hero-\(atlas.action)\(suffix).png"
        let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: output) as CFURL,
            UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, context.makeImage()!, nil)
        precondition(CGImageDestinationFinalize(destination), "Failed to save \(output)")
        print("\(output): \(atlas.frames) frames, \(frameSize)px RGBA")
    }
}
