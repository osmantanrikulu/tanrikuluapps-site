// Tanrikulu Apps marka logosu — UC KONSEPT tek sayfada (secim icin).
// Calistirma: swift tools/brand_concepts.swift /tmp/marka-konseptleri.png
// CoreGraphics + CoreText; harici bagimlilik yok (makinede magick/PIL yok).
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let W = 1400, H = 2020
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

// Zemin
ctx.setFillColor(rgba(255, 255, 255))
ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

// CG alt-soldan calisir; metin cizerken flip'e dikkat — metinleri
// CoreText ile dogrudan CG koordinatinda ciziyoruz (y = alttan).
func drawText(_ s: String, x: CGFloat, y: CGFloat, size: CGFloat,
              bold: Bool = false, color: CGColor = CGColor(gray: 0, alpha: 1),
              spacing: CGFloat = 0) {
  let font = CTFontCreateWithName(
      (bold ? "HelveticaNeue-Bold" : "HelveticaNeue") as CFString, size, nil)
  let attrs: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key(kCTFontAttributeName as String): font,
    NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
    NSAttributedString.Key(kCTKernAttributeName as String): spacing,
  ]
  let line = CTLineCreateWithAttributedString(
      NSAttributedString(string: s, attributes: attrs))
  ctx.textPosition = CGPoint(x: x, y: y)
  CTLineDraw(line, ctx)
}

func tileGradient(_ rect: CGRect, radius: CGFloat,
                  colors: [CGColor]) {
  ctx.saveGState()
  let path = CGPath(roundedRect: rect, cornerWidth: radius,
                    cornerHeight: radius, transform: nil)
  ctx.addPath(path)
  ctx.clip()
  let g = CGGradient(colorsSpace: space, colors: colors as CFArray,
                     locations: nil)!
  ctx.drawLinearGradient(g,
      start: CGPoint(x: rect.minX, y: rect.maxY),
      end: CGPoint(x: rect.maxX, y: rect.minY), options: [])
  ctx.restoreGState()
}

// Kalin "T" — harf degil sekil olarak cizilir (font suprizi olmasin).
func drawT(center: CGPoint, size: CGFloat, color: CGColor,
           barRatio: CGFloat = 0.30) {
  let bar = size * barRatio          // kol kalinligi
  let half = size / 2
  ctx.setFillColor(color)
  // ust kol
  ctx.fill(CGRect(x: center.x - half, y: center.y + half - bar,
                  width: size, height: bar))
  // govde
  ctx.fill(CGRect(x: center.x - bar / 2, y: center.y - half,
                  width: bar, height: size - bar * 0.0))
}

let tile: CGFloat = 340
let leftX: CGFloat = 90
let rowH: CGFloat = 560
// Satirlar ustten asagi: CG'de y alttan olculur.
func rowTop(_ i: Int) -> CGFloat { CGFloat(H) - 220 - CGFloat(i) * rowH }

// Baslik
drawText("Tanrikulu Apps — logo konseptleri", x: leftX, y: CGFloat(H) - 110,
         size: 52, bold: true, color: ink)
drawText("9 Agustos 2026 · secim icin uc yon", x: leftX, y: CGFloat(H) - 160,
         size: 26, color: muted)

// ---------- A: Degrade "T" karo ----------
do {
  let top = rowTop(0)
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  tileGradient(r, radius: 76, colors: [tealLight, teal, blueDeep])
  drawT(center: CGPoint(x: r.midX, y: r.midY - 8), size: tile * 0.52,
        color: CGColor(gray: 1, alpha: 1))
  // iki dikeyi temsil eden iki nokta (damla+park mavisi)
  ctx.setFillColor(rgba(255, 255, 255, 0.85))
  ctx.fillEllipse(in: CGRect(x: r.midX - 34, y: r.minY + 46,
                             width: 20, height: 20))
  ctx.fillEllipse(in: CGRect(x: r.midX + 14, y: r.minY + 46,
                             width: 20, height: 20))
  let tx = leftX + tile + 70
  drawText("A", x: tx, y: top - 60, size: 64, bold: true, color: teal)
  drawText("Degrade T karo", x: tx, y: top - 130, size: 40, bold: true,
           color: ink)
  drawText("Turkuaz-mavi gecis iki uygulamanin rengini birlestirir;", x: tx,
           y: top - 185, size: 27, color: muted)
  drawText("alttaki iki nokta aile uyeleri (yeni dikeyle cogalir).", x: tx,
           y: top - 222, size: 27, color: muted)
  drawText("Favicon ve app-store profiline dogrudan oturur.", x: tx,
           y: top - 259, size: 27, color: muted)
}

// ---------- B: Cati T ----------
do {
  let top = rowTop(1)
  let r = CGRect(x: leftX, y: top - tile, width: tile, height: tile)
  // beyaz karo + ince cerceve
  let path = CGPath(roundedRect: r, cornerWidth: 76, cornerHeight: 76,
                    transform: nil)
  ctx.addPath(path)
  ctx.setFillColor(rgba(248, 250, 252))
  ctx.fillPath()
  ctx.addPath(path)
  ctx.setStrokeColor(rgba(0xE2, 0xE8, 0xF0))
  ctx.setLineWidth(4)
  ctx.strokePath()
  // cati (kalin sapka) — gradyanli
  ctx.saveGState()
  let roof = CGMutablePath()
  let cx = r.midX, topY = r.maxY - 64
  roof.move(to: CGPoint(x: cx - 118, y: topY - 74))
  roof.addLine(to: CGPoint(x: cx, y: topY))
  roof.addLine(to: CGPoint(x: cx + 118, y: topY - 74))
  ctx.addPath(roof)
  ctx.setLineWidth(46)
  ctx.setLineCap(.round)
  ctx.setLineJoin(.round)
  ctx.replacePathWithStrokedPath()
  ctx.clip()
  let g = CGGradient(colorsSpace: space,
                     colors: [teal, blue] as CFArray, locations: nil)!
  ctx.drawLinearGradient(g, start: CGPoint(x: cx - 120, y: 0),
                         end: CGPoint(x: cx + 120, y: 0), options: [])
  ctx.restoreGState()
  // govde (T'nin bacagi)
  ctx.setFillColor(ink)
  ctx.fill(CGRect(x: cx - 23, y: r.minY + 60, width: 46, height: 148))
  // iki nokta: cati altinda damla-yesili ve park-mavisi
  ctx.setFillColor(teal)
  ctx.fillEllipse(in: CGRect(x: cx - 78, y: r.minY + 150,
                             width: 30, height: 30))
  ctx.setFillColor(blue)
  ctx.fillEllipse(in: CGRect(x: cx + 48, y: r.minY + 150,
                             width: 30, height: 30))
  let tx = leftX + tile + 70
  drawText("B", x: tx, y: top - 60, size: 64, bold: true, color: blue)
  drawText("Cati T", x: tx, y: top - 130, size: 40, bold: true, color: ink)
  drawText("'Cati marka' fikrinin kendisi: cati altinda iki dikey", x: tx,
           y: top - 185, size: 27, color: muted)
  drawText("(turkuaz damla + mavi park). Acik zeminde zarif;", x: tx,
           y: top - 222, size: 27, color: muted)
  drawText("kucuk boyutta detay kaybi riski var.", x: tx,
           y: top - 259, size: 27, color: muted)
}

// ---------- C: Uygulama ailesi (istif) ----------
do {
  let top = rowTop(2)
  let back = CGRect(x: leftX + 52, y: top - tile + 40,
                    width: tile - 60, height: tile - 60)
  tileGradient(back, radius: 60, colors: [blue, blueDeep])
  let front = CGRect(x: leftX, y: top - tile, width: tile - 60,
                     height: tile - 60)
  // on karoya golge
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30,
                color: rgba(2, 20, 27, 0.35))
  tileGradient(front, radius: 60, colors: [tealLight, teal])
  ctx.restoreGState()
  drawT(center: CGPoint(x: front.midX, y: front.midY - 6),
        size: front.width * 0.5, color: CGColor(gray: 1, alpha: 1))
  let tx = leftX + tile + 70
  drawText("C", x: tx, y: top - 60, size: 64, bold: true, color: ink)
  drawText("Uygulama ailesi", x: tx, y: top - 130, size: 40, bold: true,
           color: ink)
  drawText("One cikan turkuaz kart WashPro'yu, arkadaki mavi kart", x: tx,
           y: top - 185, size: 27, color: muted)
  drawText("OtoparkPro'yu cagristirir; 'birden cok uygulama, tek", x: tx,
           y: top - 222, size: 27, color: muted)
  drawText("cati' hissi. Yeni dikey geldikce anlam buyur.", x: tx,
           y: top - 259, size: 27, color: muted)
}

// Alt: yazi kilidi ornekleri (secilen karo + isim)
let lockY: CGFloat = 150
drawText("Yazi kilidi ornegi:", x: leftX, y: lockY + 90, size: 26,
         color: muted)
let mini = CGRect(x: leftX, y: lockY - 30, width: 84, height: 84)
tileGradient(mini, radius: 20, colors: [tealLight, teal, blueDeep])
drawT(center: CGPoint(x: mini.midX, y: mini.midY - 2), size: 44,
      color: CGColor(gray: 1, alpha: 1))
drawText("tanrikulu", x: leftX + 110, y: lockY - 4, size: 56, bold: true,
         color: ink)
drawText("apps", x: leftX + 388, y: lockY - 4, size: 56, color: teal)

// PNG yaz
let out = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "/tmp/marka-konseptleri.png"
let img = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString,
    1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("yazildi: \(out)")
