// Tanrikulu Apps site ikonu: teal degrade zemin, beyaz "T" + su damlasi.
// Kullanim: swift tools/site_icon.swift <boyut> <cikti.png>
import AppKit

let size = Int(CommandLine.arguments[1])!
let out = CommandLine.arguments[2]
let s = CGFloat(size)

let img = NSImage(size: NSSize(width: s, height: s))
img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

// Yuvarlak kose (iOS benzeri, %22)
let r = s * 0.22
let path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                  cornerWidth: r, cornerHeight: r, transform: nil)
ctx.addPath(path); ctx.clip()

// Degrade zemin
let colors = [NSColor(red: 0.03, green: 0.45, blue: 0.56, alpha: 1).cgColor,
              NSColor(red: 0.02, green: 0.71, blue: 0.83, alpha: 1).cgColor] as CFArray
let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])

// Beyaz "T"
let font = NSFont.systemFont(ofSize: s * 0.62, weight: .heavy)
let attr: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
let t = NSAttributedString(string: "T", attributes: attr)
let ts = t.size()
t.draw(at: NSPoint(x: (s - ts.width) / 2, y: (s - ts.height) / 2 + s * 0.02))

// Sag ust kosede kucuk damla
let drop = NSAttributedString(string: "💧",
  attributes: [.font: NSFont.systemFont(ofSize: s * 0.20)])
let ds = drop.size()
drop.draw(at: NSPoint(x: s * 0.66, y: s * 0.62 - ds.height / 2 + s * 0.10))

img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
rep.size = NSSize(width: s, height: s)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
