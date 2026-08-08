// Tanrikulu Apps marka logosu — SECILEN: C2 "cilali deste" (9 Agu).
// Uc katman: turkuaz (onde, T) + mavi + civit; hafif yelpaze.
// Calistirma: swift tools/brand_final.swift <boyut> <cikti.png>
// Ornek: swift tools/brand_final.swift 1024 icons/logo-1024.png
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = CommandLine.arguments.count > 1
    ? Int(CommandLine.arguments[1]) ?? 1024 : 1024
let out = CommandLine.arguments.count > 2
    ? CommandLine.arguments[2] : "/tmp/tanrikulu-logo.png"

let W = size
let space = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: W, height: W, bitsPerComponent: 8,
                    bytesPerRow: 0, space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
  CGColor(red: CGFloat(r)/255, green: CGFloat(g)/255,
          blue: CGFloat(b)/255, alpha: a)
}

let teal = rgba(0x0E, 0x74, 0x90)
let tealLight = rgba(0x22, 0xD3, 0xEE)
let blue = rgba(0x1D, 0x4E, 0xD8)
let blueDeep = rgba(0x37, 0x30, 0xA3)

func roundedGradient(_ rect: CGRect, radius: CGFloat, colors: [CGColor],
                     rotate: CGFloat = 0) {
  ctx.saveGState()
  if rotate != 0 {
    ctx.translateBy(x: rect.midX, y: rect.midY)
    ctx.rotate(by: rotate)
    ctx.translateBy(x: -rect.midX, y: -rect.midY)
  }
  ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius,
                     cornerHeight: radius, transform: nil))
  ctx.clip()
  let g = CGGradient(colorsSpace: space, colors: colors as CFArray,
                     locations: nil)!
  ctx.drawLinearGradient(g,
      start: CGPoint(x: rect.minX, y: rect.maxY),
      end: CGPoint(x: rect.maxX, y: rect.minY), options: [])
  ctx.restoreGState()
}

// Seffaf zemin; deste tuvali doldurur (kenarlarda pay birakilir).
let s = CGFloat(W) / 360.0
let card = CGFloat(W) * 0.68
let rad = card * 0.24

roundedGradient(CGRect(x: 96 * s, y: 88 * s, width: card, height: card),
                radius: rad, colors: [blueDeep, rgba(0x2A, 0x24, 0x7A)],
                rotate: 0.10)
roundedGradient(CGRect(x: 62 * s, y: 62 * s, width: card, height: card),
                radius: rad, colors: [rgba(0x3B, 0x82, 0xF6), blue],
                rotate: 0.05)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12 * s), blur: 30 * s,
              color: rgba(2, 20, 27, 0.35))
let front = CGRect(x: 28 * s, y: 36 * s, width: card, height: card)
roundedGradient(front, radius: rad, colors: [tealLight, teal])
ctx.restoreGState()

// T
let tSize = card * 0.5
let bar = tSize * 0.30
let half = tSize / 2
ctx.setFillColor(CGColor(gray: 1, alpha: 1))
ctx.fill(CGRect(x: front.midX - half, y: front.midY + half - bar,
                width: tSize, height: bar))
ctx.fill(CGRect(x: front.midX - bar / 2, y: front.midY - half,
                width: bar, height: tSize))

let img = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString,
    1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("yazildi: \(out) (\(W)x\(W))")
