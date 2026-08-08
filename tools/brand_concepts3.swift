// Tanrikulu Apps logo — FINAL TUR: sayidan bagimsiz uc aday.
// Osman'in sarti (9 Agu): logo uygulama SAYISINI kodlamasin (2 nokta /
// 2 tabela buyuyen ailede eskir). Calistirma:
//   swift tools/brand_concepts3.swift /tmp/marka-final.png
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let W = 1400, H = 2150
let space = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8,
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
let ink = rgba(0x0F, 0x17, 0x2A)
let navy = rgba(0x0B, 0x1F, 0x33)
let muted = rgba(0x64, 0x74, 0x8B)

ctx.setFillColor(rgba(255, 255, 255))
ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

func drawText(_ s: String, x: CGFloat, y: CGFloat, size: CGFloat,
              bold: Bool = false,
              color: CGColor = CGColor(gray: 0, alpha: 1)) {
  let font = CTFontCreateWithName(
      (bold ? "HelveticaNeue-Bold" : "HelveticaNeue") as CFString, size, nil)
  let attrs: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key(kCTFontAttributeName as String): font,
    NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
  ]
  let line = CTLineCreateWithAttributedString(
      NSAttributedString(string: s, attributes: attrs))
  ctx.textPosition = CGPoint(x: x, y: y)
  CTLineDraw(line, ctx)
}

func tileGradient(_ rect: CGRect, radius: CGFloat, colors: [CGColor]) {
  ctx.saveGState()
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

func drawT(center: CGPoint, size: CGFloat, color: CGColor) {
  let bar = size * 0.30
  let half = size / 2
  ctx.setFillColor(color)
  ctx.fill(CGRect(x: center.x - half, y: center.y + half - bar,
                  width: size, height: bar))
  ctx.fill(CGRect(x: center.x - bar / 2, y: center.y - half,
                  width: bar, height: size - bar * 0.0))
}

/// Kucultulmus favicon onizlemesi (32 px esdegeri).
func favicon(_ x: CGFloat, _ y: CGFloat, draw: (CGRect) -> Void) {
  let r = CGRect(x: x, y: y, width: 64, height: 64)
  draw(r)
  drawText("32 px", x: x + 6, y: y - 30, size: 20, color: muted)
}

let tile: CGFloat = 340
let leftX: CGFloat = 90
let rowH: CGFloat = 620
func rowTop(_ i: Int) -> CGFloat { CGFloat(H) - 230 - CGFloat(i) * rowH }

drawText("Tanrikulu Apps — final tur (sayidan bagimsiz)", x: leftX,
         y: CGFloat(H) - 110, size: 50, bold: true, color: ink)
drawText("Hicbiri uygulama sayisini kodlamiyor; aile buyuse de eskimez.",
         x: leftX, y: CGFloat(H) - 158, size: 26, color: muted)

// ---------- A2: Degrade T karo (noktasiz, sade) ----------
func drawA(_ r: CGRect) {
  tileGradient(r, radius: r.width * 0.22, colors: [tealLight, teal, blueDeep])
  drawT(center: CGPoint(x: r.midX, y: r.midY), size: r.width * 0.54,
        color: CGColor(gray: 1, alpha: 1))
}
do {
  let top = rowTop(0)
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  drawA(r)
  favicon(leftX + tile + 46, top - tile + 30) { drawA($0) }
  let tx = leftX + tile + 170
  drawText("A2", x: tx, y: top - 60, size: 56, bold: true, color: teal)
  drawText("Degrade T karo — sade", x: tx, y: top - 126, size: 38,
           bold: true, color: ink)
  drawText("1. turdaki A'nin noktasiz hali: yalniz harf ve renk", x: tx,
           y: top - 178, size: 26, color: muted)
  drawText("gecisi. En dayanikli, en cok yerde calisan aday.", x: tx,
           y: top - 214, size: 26, color: muted)
}

// ---------- D2: Yol T ----------
func drawD(_ r: CGRect) {
  tileGradient(r, radius: r.width * 0.22,
               colors: [rgba(0x11, 0x2A, 0x42), navy])
  let s = r.width / 340.0
  ctx.setFillColor(rgba(0x1E, 0x33, 0x50))
  let armH = 92 * s
  ctx.fill(CGRect(x: r.minX, y: r.maxY - 70 * s - armH,
                  width: r.width, height: armH))
  ctx.fill(CGRect(x: r.midX - armH / 2, y: r.minY,
                  width: armH, height: r.height - 70 * s - armH + 8 * s))
  func dash(_ x: CGFloat, _ y: CGFloat, w: CGFloat, h: CGFloat,
            _ c: CGColor) {
    ctx.setFillColor(c)
    ctx.addPath(CGPath(roundedRect: CGRect(x: x, y: y, width: w, height: h),
                       cornerWidth: min(w, h) / 2,
                       cornerHeight: min(w, h) / 2, transform: nil))
    ctx.fillPath()
  }
  let cy = r.maxY - 70 * s - armH / 2
  dash(r.minX + 28 * s, cy - 5 * s, w: 44 * s, h: 10 * s, tealLight)
  dash(r.minX + 96 * s, cy - 5 * s, w: 44 * s, h: 10 * s,
       CGColor(gray: 1, alpha: 0.9))
  dash(r.midX + 52 * s, cy - 5 * s, w: 44 * s, h: 10 * s,
       CGColor(gray: 1, alpha: 0.9))
  dash(r.midX + 120 * s, cy - 5 * s, w: 44 * s, h: 10 * s,
       rgba(0x60, 0xA5, 0xFA))
  var y = cy - armH / 2 - 40 * s
  var i = 0
  while y > r.minY + 24 * s {
    dash(r.midX - 5 * s, y - 40 * s, w: 10 * s, h: 40 * s,
         i % 2 == 0 ? CGColor(gray: 1, alpha: 0.9) : tealLight)
    y -= 68 * s
    i += 1
  }
}
do {
  let top = rowTop(1)
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  drawD(r)
  favicon(leftX + tile + 46, top - tile + 30) { drawD($0) }
  let tx = leftX + tile + 170
  drawText("D2", x: tx, y: top - 60, size: 56, bold: true, color: tealLight)
  drawText("Yol T", x: tx, y: top - 126, size: 38, bold: true, color: ink)
  drawText("Kavsak kusbakisi T; seritler marka renkleri. Hikayesi:", x: tx,
           y: top - 178, size: 26, color: muted)
  drawText("butun dikeyler ayni yolda. Koyu zeminde cok secilir.", x: tx,
           y: top - 214, size: 26, color: muted)
}

// ---------- G2: Igne T ----------
func drawG(_ r: CGRect) {
  let s = r.width / 340.0
  tileGradient(r, radius: r.width * 0.22,
               colors: [rgba(0xEB, 0xF7, 0xFA), rgba(0xE5, 0xED, 0xFB)])
  let cx = r.midX
  let cy = r.midY + 42 * s
  let R = 104 * s
  let pin = CGMutablePath()
  pin.addArc(center: CGPoint(x: cx, y: cy), radius: R,
             startAngle: .pi * 1.25, endAngle: .pi * -0.25,
             clockwise: false)
  pin.addLine(to: CGPoint(x: cx, y: cy - R - 96 * s))
  pin.closeSubpath()
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: -8 * s), blur: 20 * s,
                color: rgba(2, 20, 27, 0.28))
  ctx.addPath(pin)
  ctx.clip()
  let g = CGGradient(colorsSpace: space,
                     colors: [tealLight, teal, blue] as CFArray,
                     locations: nil)!
  ctx.drawLinearGradient(g, start: CGPoint(x: cx, y: cy + R),
                         end: CGPoint(x: cx, y: cy - R - 96 * s),
                         options: [])
  ctx.restoreGState()
  ctx.setFillColor(CGColor(gray: 1, alpha: 1))
  ctx.fill(CGRect(x: cx - 62 * s, y: cy + 18 * s,
                  width: 124 * s, height: 38 * s))
  ctx.fill(CGRect(x: cx - 19 * s, y: cy - 78 * s,
                  width: 38 * s, height: 96 * s))
}
do {
  let top = rowTop(2)
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  drawG(r)
  favicon(leftX + tile + 46, top - tile + 30) { drawG($0) }
  let tx = leftX + tile + 170
  drawText("G2", x: tx, y: top - 60, size: 56, bold: true, color: blue)
  drawText("Igne T", x: tx, y: top - 126, size: 38, bold: true, color: ink)
  drawText("Harita ignesinde T: 'yakinindaki isletme' stratejisi.", x: tx,
           y: top - 178, size: 26, color: muted)
  drawText("Ortak harita ve CarPlay vizyonuyla ayni dilde.", x: tx,
           y: top - 214, size: 26, color: muted)
}

// Yazi kilitleri
let lockY: CGFloat = 140
drawText("Yazi kilidi (A2 ile):", x: leftX, y: lockY + 96, size: 25,
         color: muted)
let mini = CGRect(x: leftX, y: lockY - 26, width: 84, height: 84)
drawA(mini)
drawText("tanrikulu", x: leftX + 108, y: lockY, size: 54, bold: true,
         color: ink)
drawText("apps", x: leftX + 376, y: lockY, size: 54, color: teal)

let out = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "/tmp/marka-final.png"
let img = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString,
    1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("yazildi: \(out)")
