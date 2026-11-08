// Export generated artwork into the existing eight-frame Arka file layout.
// swift -module-cache-path /tmp/niskala-swift-cache tools/export_arka_hd.swift [output-root]
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let outputRoot = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "assets/images/player/arka"
let actions = ["idle", "run", "attack_1", "attack_2"]
let facings = ["right", "left", "up", "down"]
let frameWidth = 384, frameHeight = 320

struct Frame {
    let image: CGImage
    let body: CGRect
    let footX: Double
}

func inspect(_ image: CGImage) -> Frame {
    let width = image.width, height = image.height
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
        bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    // Image rows in this bitmap buffer follow source image row order.
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    let data = ctx.data!.assumingMemoryBound(to: UInt8.self)
    var points: [(Int, Int)] = []
    for y in 0..<height {
        for x in 0..<width {
            let index = (y * width + x) * 4
            let r = Int(data[index]), g = Int(data[index + 1]), b = Int(data[index + 2])
            // Warm hair, cloth, leather and boots identify the body separately
            // from neutral silver swords and pale slash effects.
            if data[index + 3] > 160 && r > g + 8 && r > b + 8 {
                points.append((x, y))
            }
        }
    }
    precondition(points.count > 40, "No readable warm-palette body found")
    let minX = points.map { $0.0 }.min()!, maxX = points.map { $0.0 }.max()!
    let minY = points.map { $0.1 }.min()!, maxY = points.map { $0.1 }.max()!
    let body = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    let footPoints = points.filter { Double($0.1) >= Double(maxY) - Double(body.height) * 0.18 }
    let footX = Double(footPoints.reduce(0) { $0 + $1.0 }) / Double(footPoints.count)
    return Frame(image: image, body: body, footX: footX)
}

for action in actions {
    let input = URL(fileURLWithPath: "docs/art/arka-hd/\(action)-atlas.png")
    let source = CGImageSourceCreateWithURL(input as CFURL, nil)!
    let atlas = CGImageSourceCreateImageAtIndex(source, 0, nil)!
    let cellW = Double(atlas.width) / 8, cellH = Double(atlas.height) / 4
    var rows: [[Frame]] = []
    for row in 0..<4 {
        var frames: [Frame] = []
        for column in 0..<8 {
            // Extend only the side where the first slash crosses the gutter;
            // including both sides can pick up the next pose's effect.
            let leading = action == "attack_1" && column == 1 && row == 1 ? cellW * 0.20 : 0
            let trailing = action == "attack_1" && column == 1 && row == 0 ? cellW * 0.20 : 0
            let frame = atlas.cropping(to: CGRect(x: (Double(column) * cellW - leading).rounded(),
                y: (Double(row) * cellH).rounded(), width: (cellW + leading + trailing).rounded(.down), height: cellH.rounded(.down)))!
            frames.append(inspect(frame))
        }
        rows.append(frames)
    }
    // One scale per action preserves relative pose motion across all frames.
    let heights = rows.flatMap { $0 }.map { Double($0.body.height) }.sorted()
    let scale = 128.0 / heights[heights.count / 2]
    for (row, facing) in facings.enumerated() {
        let ctx = CGContext(data: nil, width: frameWidth * 8, height: frameHeight,
            bitsPerComponent: 8, bytesPerRow: frameWidth * 8 * 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.interpolationQuality = .high
        for (index, frame) in rows[row].enumerated() {
            let width = Double(frame.image.width) * scale
            let height = Double(frame.image.height) * scale
            let x = Double(index * frameWidth) + 192 - frame.footX * scale
            let top = 232 - Double(frame.body.maxY) * scale
            ctx.saveGState()
            ctx.clip(to: CGRect(x: index * frameWidth, y: 0, width: frameWidth, height: frameHeight))
            ctx.draw(frame.image, in: CGRect(x: x, y: Double(frameHeight) - top - height, width: width, height: height))
            ctx.restoreGState()
        }
        let directory = URL(fileURLWithPath: "\(outputRoot)/\(action)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let name = action.replacingOccurrences(of: "_", with: "")
        let target = directory.appendingPathComponent("\(name)_\(facing).png")
        let dest = CGImageDestinationCreateWithURL(target as CFURL, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
        precondition(CGImageDestinationFinalize(dest))
        print("\(target.path): 8 frames, \(frameWidth)x\(frameHeight), body scale \(scale)")
    }
}
