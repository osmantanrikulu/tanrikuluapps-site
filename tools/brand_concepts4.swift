// Tanrikulu Apps logo — 4. tur: Osman'in secimi C'nin cilalanmasi.
//   C2: uc katmanli "uygulama destesi" (sayi hissi jenerik) + on yuzde T
//   C3: GERCEK uygulama ikonlarindan olusan deste (WashPro + OtoparkPro
//       + gelecegi ima eden "+" karti)
// Calistirma: swift tools/brand_concepts4.swift /tmp/marka-c.png
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let W = 1400, H = 1560
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

func drawT(center: CGPoint, size: CGFloat) {
  let bar = size * 0.30
  let half = size / 2
  ctx.setFillColor(CGColor(gray: 1, alpha: 1))
  ctx.fill(CGRect(x: center.x - half, y: center.y + half - bar,
                  width: size, height: bar))
  ctx.fill(CGRect(x: center.x - bar / 2, y: center.y - half,
                  width: bar, height: size - bar * 0.0))
}

func loadPng(_ path: String) -> CGImage? {
  guard let src = CGImageSourceCreateWithURL(
      URL(fileURLWithPath: path) as CFURL, nil) else { return nil }
  return CGImageSourceCreateImageAtIndex(src, 0, nil)
}

/// Yuvarlak koseyle kirparak resim ciz (uygulama ikonu gibi).
func drawImageTile(_ img: CGImage, in rect: CGRect, radius: CGFloat,
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
  // CG resmi ters cizer; kirpma icinde dikeyde cevir.
  ctx.translateBy(x: 0, y: rect.midY * 2)
  ctx.scaleBy(x: 1, y: -1)
  ctx.draw(img, in: CGRect(x: rect.minX, y: rect.minY,
                           width: rect.width, height: rect.height))
  ctx.restoreGState()
}

func shadowOn() {
  ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 30,
                color: rgba(2, 20, 27, 0.35))
}

// ---------- C2: Cilali deste (soyut) ----------
func drawC2(_ r: CGRect) {
  let s = r.width / 360.0
  let card = r.width * 0.68
  let rad = card * 0.24
  // arka: civit — hafif sola yatik
  ctx.saveGState()
  roundedGradient(CGRect(x: r.minX + 96 * s, y: r.minY + 88 * s,
                         width: card, height: card),
                  radius: rad, colors: [blueDeep, rgba(0x2A, 0x24, 0x7A)],
                  rotate: 0.10)
  ctx.restoreGState()
  // orta: mavi
  roundedGradient(CGRect(x: r.minX + 62 * s, y: r.minY + 62 * s,
                         width: card, height: card),
                  radius: rad, colors: [rgba(0x3B, 0x82, 0xF6), blue],
                  rotate: 0.05)
  // on: turkuaz + T, golgeli
  ctx.saveGState()
  shadowOn()
  let front = CGRect(x: r.minX + 28 * s, y: r.minY + 36 * s,
                     width: card, height: card)
  roundedGradient(front, radius: rad, colors: [tealLight, teal])
  ctx.restoreGState()
  drawT(center: CGPoint(x: front.midX, y: front.midY), size: card * 0.5)
}

// ---------- C3: Gercek ikon destesi ----------
let washImg = loadPng(NSString(
    string: "~/Documents/GitHub/WashPro/assets/logo/washpro_icon_256.png")
    .expandingTildeInPath)
let parkImg = loadPng(NSString(
    string: "~/Documents/GitHub/OtoparkPro/assets/logo/otoparkpro_icon.png")
    .expandingTildeInPath)

func drawC3(_ r: CGRect) {
  let s = r.width / 360.0
  let card = r.width * 0.62
  let rad = card * 0.24
  // en arka: "+" karti — aile buyuyecek imasi
  let plus = CGRect(x: r.minX + 128 * s, y: r.minY + 104 * s,
                    width: card, height: card)
  ctx.saveGState()
  ctx.addPath(CGPath(roundedRect: plus, cornerWidth: rad,
                     cornerHeight: rad, transform: nil))
  ctx.setFillColor(rgba(0xE2, 0xE8, 0xF0))
  ctx.fillPath()
  ctx.setFillColor(rgba(0x94, 0xA3, 0xB8))
  let pw = 12 * s, pl = 56 * s
  ctx.fill(CGRect(x: plus.midX - pl / 2, y: plus.midY - pw / 2,
                  width: pl, height: pw))
  ctx.fill(CGRect(x: plus.midX - pw / 2, y: plus.midY - pl / 2,
                  width: pw, height: pl))
  ctx.restoreGState()
  // orta: OtoparkPro ikonu
  if let p = parkImg {
    ctx.saveGState()
    shadowOn()
    drawImageTile(p, in: CGRect(x: r.minX + 82 * s, y: r.minY + 70 * s,
                                width: card, height: card),
                  radius: rad, rotate: 0.05)
    ctx.restoreGState()
  }
  // on: WashPro ikonu
  if let w = washImg {
    ctx.saveGState()
    shadowOn()
    drawImageTile(w, in: CGRect(x: r.minX + 30 * s, y: r.minY + 38 * s,
                                width: card, height: card),
                  radius: rad)
    ctx.restoreGState()
  }
}

let tile: CGFloat = 380
let leftX: CGFloat = 90

drawText("C konsepti — cilali iki varyant", x: leftX, y: CGFloat(H) - 110,
         size: 50, bold: true, color: ink)

// C2 satiri
do {
  let top = CGFloat(H) - 230
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  drawC2(r)
  // favicon onizleme
  let f = CGRect(x: leftX + tile + 60, y: top - tile + 40,
                 width: 72, height: 72)
  drawC2(f)
  drawText("32 px", x: f.minX + 8, y: f.minY - 30, size: 20, color: muted)
  let tx = leftX + tile + 190
  drawText("C2 — Cilali deste", x: tx, y: top - 70, size: 40, bold: true,
           color: ink)
  drawText("Uc katman: turkuaz (on) + mavi + civit. 'Coklu", x: tx,
           y: top - 126, size: 26, color: muted)
  drawText("uygulama' hissi sayiya baglanmadan verilir;", x: tx,
           y: top - 162, size: 26, color: muted)
  drawText("hafif yelpaze donusu marka canliligi katar.", x: tx,
           y: top - 198, size: 26, color: muted)
}

// C3 satiri
do {
  let top = CGFloat(H) - 230 - 620
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  drawC3(r)
  let f = CGRect(x: leftX + tile + 60, y: top - tile + 40,
                 width: 72, height: 72)
  drawC3(f)
  drawText("32 px", x: f.minX + 8, y: f.minY - 30, size: 20, color: muted)
  let tx = leftX + tile + 190
  drawText("C3 — Gercek ikon destesi", x: tx, y: top - 70, size: 40,
           bold: true, color: ink)
  drawText("WashPro onde, OtoparkPro arkada, en arkada '+':", x: tx,
           y: top - 126, size: 26, color: muted)
  drawText("aile buyuyecek mesaji. CANLI ve tanidik; bedeli,", x: tx,
           y: top - 162, size: 26, color: muted)
  drawText("uygulama ikonu degisirse logonun da degismesi ve", x: tx,
           y: top - 198, size: 26, color: muted)
  drawText("kucuk boyutta detay yogunlugu (32 px'e bak).", x: tx,
           y: top - 234, size: 26, color: muted)
}

let out = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "/tmp/marka-c.png"
let img = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString,
    1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("yazildi: \(out)")
