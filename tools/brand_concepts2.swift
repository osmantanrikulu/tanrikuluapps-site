// Tanrikulu Apps logo — 2. TUR: daha yaratici dort yon (secim sayfasi).
// Calistirma: swift tools/brand_concepts2.swift /tmp/marka-konseptleri-2.png
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let W = 1400, H = 2100
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
let slate = rgba(0x47, 0x55, 0x69)

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

func tileGradient(_ rect: CGRect, radius: CGFloat, colors: [CGColor],
                  diag: Bool = true) {
  ctx.saveGState()
  ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius,
                     cornerHeight: radius, transform: nil))
  ctx.clip()
  let g = CGGradient(colorsSpace: space, colors: colors as CFArray,
                     locations: nil)!
  ctx.drawLinearGradient(g,
      start: CGPoint(x: rect.minX, y: diag ? rect.maxY : rect.midY),
      end: CGPoint(x: rect.maxX, y: diag ? rect.minY : rect.midY),
      options: [])
  ctx.restoreGState()
}

func tileFlat(_ rect: CGRect, radius: CGFloat, color: CGColor,
              border: CGColor? = nil) {
  let p = CGPath(roundedRect: rect, cornerWidth: radius,
                 cornerHeight: radius, transform: nil)
  ctx.addPath(p)
  ctx.setFillColor(color)
  ctx.fillPath()
  if let b = border {
    ctx.addPath(p)
    ctx.setStrokeColor(b)
    ctx.setLineWidth(4)
    ctx.strokePath()
  }
}

let tile: CGFloat = 360
let colX: [CGFloat] = [90, 740]
let rowY: [CGFloat] = [CGFloat(H) - 260, CGFloat(H) - 260 - 700]

drawText("Tanrikulu Apps — logo konseptleri, 2. tur", x: 90,
         y: CGFloat(H) - 110, size: 52, bold: true, color: ink)
drawText("Daha yaratici dort yon — hepsi isin dunyasindan", x: 90,
         y: CGFloat(H) - 160, size: 26, color: muted)

// ---------- D: Yol T (gece yolu, serit cizgileri) ----------
do {
  let r = CGRect(x: colX[0], y: rowY[0] - tile, width: tile, height: tile)
  tileGradient(r, radius: 80, colors: [rgba(0x11, 0x2A, 0x42), navy])
  // yatay yol (T'nin kolu) + dikey yol (T'nin govdesi)
  ctx.setFillColor(rgba(0x1E, 0x33, 0x50))
  let armH: CGFloat = 92
  ctx.fill(CGRect(x: r.minX, y: r.maxY - 70 - armH, width: tile, height: armH))
  ctx.fill(CGRect(x: r.midX - armH / 2, y: r.minY,
                  width: armH, height: tile - 70 - armH + 8))
  // serit cizgileri: marka renkleriyle kesik cizgi
  func dash(_ x: CGFloat, _ y: CGFloat, w: CGFloat, h: CGFloat,
            _ c: CGColor) {
    ctx.setFillColor(c)
    ctx.addPath(CGPath(roundedRect: CGRect(x: x, y: y, width: w, height: h),
                       cornerWidth: min(w, h) / 2,
                       cornerHeight: min(w, h) / 2, transform: nil))
    ctx.fillPath()
  }
  let cy = r.maxY - 70 - armH / 2
  dash(r.minX + 28, cy - 5, w: 44, h: 10, tealLight)
  dash(r.minX + 96, cy - 5, w: 44, h: 10, CGColor(gray: 1, alpha: 0.9))
  dash(r.midX + 52, cy - 5, w: 44, h: 10, CGColor(gray: 1, alpha: 0.9))
  dash(r.midX + 120, cy - 5, w: 44, h: 10, rgba(0x60, 0xA5, 0xFA))
  var y = cy - armH / 2 - 40
  var i = 0
  while y > r.minY + 24 {
    dash(r.midX - 5, y - 40, w: 10, h: 40,
         i % 2 == 0 ? CGColor(gray: 1, alpha: 0.9) : tealLight)
    y -= 68
    i += 1
  }
  let tx = colX[0]
  drawText("D", x: tx, y: rowY[0] - tile - 70, size: 56, bold: true,
           color: tealLight)
  drawText("Yol T", x: tx + 60, y: rowY[0] - tile - 70, size: 38,
           bold: true, color: ink)
  drawText("Kavsak kusbakisi bir T: serit cizgileri marka", x: tx,
           y: rowY[0] - tile - 118, size: 25, color: muted)
  drawText("renklerinde. Butun dikeyler ayni yolda bulusur.", x: tx,
           y: rowY[0] - tile - 152, size: 25, color: muted)
}

// ---------- E: Tabela diregi ----------
do {
  let r = CGRect(x: colX[1], y: rowY[0] - tile, width: tile, height: tile)
  tileFlat(r, radius: 80, color: rgba(0xF8, 0xFA, 0xFC),
           border: rgba(0xE2, 0xE8, 0xF0))
  let cx = r.midX
  // direk + ust kol = dogal bir T
  ctx.setFillColor(ink)
  ctx.fill(CGRect(x: cx - 14, y: r.minY + 44, width: 28, height: 220))
  ctx.addPath(CGPath(roundedRect: CGRect(x: cx - 118, y: r.minY + 250,
                                         width: 236, height: 26),
                     cornerWidth: 13, cornerHeight: 13, transform: nil))
  ctx.fillPath()
  // koldan sarkan iki tabela (iki uygulama)
  func sign(_ x: CGFloat, _ c1: CGColor, _ c2: CGColor) {
    ctx.setStrokeColor(rgba(0x94, 0xA3, 0xB8))
    ctx.setLineWidth(6)
    ctx.move(to: CGPoint(x: x + 33, y: r.minY + 250))
    ctx.addLine(to: CGPoint(x: x + 33, y: r.minY + 226))
    ctx.strokePath()
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 14,
                  color: rgba(2, 20, 27, 0.25))
    tileGradient(CGRect(x: x, y: r.minY + 160, width: 66, height: 66),
                 radius: 16, colors: [c1, c2])
    ctx.restoreGState()
  }
  sign(cx - 100, tealLight, teal)
  sign(cx + 34, rgba(0x60, 0xA5, 0xFA), blue)
  // zemin golgesi
  ctx.setFillColor(rgba(0x0F, 0x17, 0x2A, 0.12))
  ctx.fillEllipse(in: CGRect(x: cx - 70, y: r.minY + 30,
                             width: 140, height: 18))
  let tx = colX[1]
  drawText("E", x: tx, y: rowY[0] - tile - 70, size: 56, bold: true,
           color: teal)
  drawText("Tabela diregi", x: tx + 56, y: rowY[0] - tile - 70, size: 38,
           bold: true, color: ink)
  drawText("Esnafin hayati tabelasidir: direk dogal bir T,", x: tx,
           y: rowY[0] - tile - 118, size: 25, color: muted)
  drawText("asili her tabela bir uygulama. Aile buyudukce artar.", x: tx,
           y: rowY[0] - tile - 152, size: 25, color: muted)
}

// ---------- F: Bijon T (altigen somun) ----------
do {
  let r = CGRect(x: colX[0], y: rowY[1] - tile, width: tile, height: tile)
  tileFlat(r, radius: 80, color: rgba(0xF8, 0xFA, 0xFC),
           border: rgba(0xE2, 0xE8, 0xF0))
  // altigen (duz-tepeli)
  let cx = r.midX, cy = r.midY, R: CGFloat = 132
  let hex = CGMutablePath()
  for k in 0..<6 {
    let a = CGFloat(k) * .pi / 3 + .pi / 6
    let p = CGPoint(x: cx + R * cos(a), y: cy + R * sin(a))
    if k == 0 { hex.move(to: p) } else { hex.addLine(to: p) }
  }
  hex.closeSubpath()
  ctx.saveGState()
  ctx.addPath(hex)
  ctx.clip()
  let g = CGGradient(colorsSpace: space,
                     colors: [tealLight, teal, blueDeep] as CFArray,
                     locations: nil)!
  ctx.drawLinearGradient(g, start: CGPoint(x: cx - R, y: cy + R),
                         end: CGPoint(x: cx + R, y: cy - R), options: [])
  ctx.restoreGState()
  // beyaz T
  ctx.setFillColor(CGColor(gray: 1, alpha: 1))
  ctx.fill(CGRect(x: cx - 78, y: cy + 28, width: 156, height: 46))
  ctx.fill(CGRect(x: cx - 23, y: cy - 92, width: 46, height: 120))
  let tx = colX[0]
  drawText("F", x: tx, y: rowY[1] - tile - 70, size: 56, bold: true,
           color: blueDeep)
  drawText("Bijon T", x: tx + 48, y: rowY[1] - tile - 70, size: 38,
           bold: true, color: ink)
  drawText("Bijon somunu: arac dunyasinin en saglam parcasi.", x: tx,
           y: rowY[1] - tile - 118, size: 25, color: muted)
  drawText("Teknik, guclu, erkeksi bir marka duruyor.", x: tx,
           y: rowY[1] - tile - 152, size: 25, color: muted)
}

// ---------- G: Igne T (harita pini) ----------
do {
  let r = CGRect(x: colX[1], y: rowY[1] - tile, width: tile, height: tile)
  tileGradient(r, radius: 80,
               colors: [rgba(0xEB, 0xF7, 0xFA), rgba(0xE5, 0xED, 0xFB)])
  let cx = r.midX
  let cy = r.midY + 42
  let R: CGFloat = 104
  // pin: daire + alt sivri
  let pin = CGMutablePath()
  pin.addArc(center: CGPoint(x: cx, y: cy), radius: R,
             startAngle: .pi * 1.25, endAngle: .pi * -0.25,
             clockwise: false)
  pin.addLine(to: CGPoint(x: cx, y: cy - R - 96))
  pin.closeSubpath()
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24,
                color: rgba(2, 20, 27, 0.28))
  ctx.addPath(pin)
  ctx.clip()
  let g = CGGradient(colorsSpace: space,
                     colors: [tealLight, teal, blue] as CFArray,
                     locations: nil)!
  ctx.drawLinearGradient(g, start: CGPoint(x: cx, y: cy + R),
                         end: CGPoint(x: cx, y: cy - R - 96), options: [])
  ctx.restoreGState()
  // beyaz T pin icinde
  ctx.setFillColor(CGColor(gray: 1, alpha: 1))
  ctx.fill(CGRect(x: cx - 62, y: cy + 18, width: 124, height: 38))
  ctx.fill(CGRect(x: cx - 19, y: cy - 78, width: 38, height: 96))
  let tx = colX[1]
  drawText("G", x: tx, y: rowY[1] - tile - 70, size: 56, bold: true,
           color: blue)
  drawText("Igne T", x: tx + 62, y: rowY[1] - tile - 70, size: 38,
           bold: true, color: ink)
  drawText("Harita ignesinin icinde T: 'yakinindaki isletme'", x: tx,
           y: rowY[1] - tile - 118, size: 25, color: muted)
  drawText("stratejisinin logosu. Ortak harita vizyonuyla birebir.", x: tx,
           y: rowY[1] - tile - 152, size: 25, color: muted)
}

// Alt not
drawText("Not: 1. turdaki A (degrade T karo) hala masada — bu dort yon ona alternatif.",
         x: 90, y: 120, size: 25, color: muted)

let out = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "/tmp/marka-konseptleri-2.png"
let img = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString,
    1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("yazildi: \(out)")
